import SwiftUI
import PayPal

class PaymentViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessfullyOrderSheet = false
    @Published var sellerStatus: SellerStatus?
    @Published var availableVouchers: [VoucherModel] = []
    @Published var selectedVoucher: VoucherModel?
    @Published var showVoucherSheet = false
    
    func processPayment(products: [CartItem], totalAmount: Double) async {
        guard let firstProduct = products.first else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Create platform order
            let orderId = try await SBPaypalService.shared.createPlatformOrder(
                amount: totalAmount,
                sellerId: firstProduct.sellerId,
                sellerPaypalMerchantId: "CZK98ESTY2PL2" // Get this from your database
            )
            
            // Start PayPal checkout
            let request = PayPalWebCheckoutRequest(
                orderID: orderId,
                fundingSource: .paypal
            )
            
            let result = try await SBPaypalService.shared.payPalClient.start(request: request)
            
            // Capture the payment
            try await SBPaypalService.shared.captureOrder(orderId: orderId)
            
            // Clear cart and show success
            DispatchQueue.main.async {
                self.isLoading = false
                self.showSuccessfullyOrderSheet = true
                SBUserDefaultService.instance.clearCart()
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func onboardSeller(email: String, businessName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let sellerId = UserRepository.shared.currentUser?.id ?? ""
            let onboardingUrl = try await SBPaypalService.shared.onboardSeller(
                sellerId: sellerId,
                email: email,
                businessName: businessName
            )
            
            // Store the onboarding URL for later use
            DispatchQueue.main.async {
                self.isLoading = false
                UserModeManager.shared.paypalOnboardingURL = onboardingUrl
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func checkSellerStatus(merchantId: String) async {
        isLoading = true
        
        do {
            let status = try await SBPaypalService.shared.checkSellerStatus(sellerMerchantId: merchantId)
            DispatchQueue.main.async {
                self.sellerStatus = status
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func fetchAvailableVouchers(userId: String, orderTotal: Double) {
        isLoading = true
        errorMessage = nil
        
        VoucherRepository.shared.getAvailableVouchers(userId: userId, orderTotal: orderTotal) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let vouchers):
                    self?.availableVouchers = vouchers
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func recordVoucherUsage(code: String, userId: String, orderId: String) {
        VoucherRepository.shared.recordVoucherUsage(code: code, userId: userId, orderId: orderId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Voucher usage recorded successfully")
                case .failure(let error):
                    self?.errorMessage = "Failed to record voucher usage: \(error.localizedDescription)"
                }
            }
        }
    }
    
    var discountedTotal: (total: Double, discount: Double) {
        guard let voucher = selectedVoucher else {
            return (total: 0, discount: 0)
        }
        
        let discount: Double
        if voucher.type == VoucherType.percentage.rawValue {
            discount = voucher.value / 100.0
        } else {
            discount = voucher.value
        }
        
        return (total: -discount, discount: discount)
    }
}

struct PaymentMethod: Identifiable {
    var id = UUID()
    var name: String
    var subtitle: String
    var color: Color
    let imageName: String
}

let paymentMethods: [PaymentMethod] = [
    PaymentMethod(name: "PayPal", subtitle: "Platform Payment", color: .orange, imageName: "img_paypal")
]
