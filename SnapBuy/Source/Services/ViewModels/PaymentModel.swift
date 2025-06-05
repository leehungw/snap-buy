import SwiftUI
import PayPal

class PaymentViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessfullyOrderSheet = false
    @Published var sellerStatus: SellerStatus?
    
    func processPayment(products: [CartItem], totalAmount: Double) async {
        guard let firstProduct = products.first else { return }
        isLoading = true
        errorMessage = nil
        
        // Fetch seller merchant id from backend
        let sellerId = firstProduct.sellerId
        var sellerMerchantId: String? = nil
        let semaphore = DispatchSemaphore(value: 0)
        UserRepository.shared.fetchUserById(userId: sellerId) { result in
            switch result {
            case .success(let userData):
                sellerMerchantId = userData.sellerMerchantId
            case .failure(let error):
                self.errorMessage = "Failed to fetch seller info: \(error.localizedDescription)"
            }
            semaphore.signal()
        }
        semaphore.wait()
        
        guard let merchantId = sellerMerchantId, !merchantId.isEmpty else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Seller has not connected PayPal."
            }
            return
        }
        
        do {
            // Create platform order
            let orderId = try await SBPaypalService.shared.createPlatformOrder(
                amount: totalAmount,
                sellerId: sellerId,
                sellerPaypalMerchantId: merchantId
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
    
    func createOrder(products: [CartItem], totalAmount: Double, shippingAddress: String, phoneNumber: String, status: String = "Pending", completion: @escaping (Bool, String?) -> Void) {
        guard let buyerId = UserRepository.shared.currentUser?.id,
              let firstProduct = products.first else {
            completion(false, "User or product info missing")
            return
        }
        let sellerId = firstProduct.sellerId
        let items: [SBOrderItemModel] = products.map { cartItem in
            SBOrderItemModel(
                id: 0,
                orderId: "string",
                productId: cartItem.productId,
                productName: cartItem.title,
                productImageUrl: cartItem.imageName,
                productNote: "",
                productVariantId: cartItem.variantId,
                quantity: cartItem.quantity,
                unitPrice: cartItem.price,
                isReviewed: false
            )
        }
        isLoading = true
        errorMessage = nil
        OrderRepository.shared.createOrder(
            buyerId: buyerId,
            sellerId: sellerId,
            totalAmount: totalAmount,
            shippingAddress: shippingAddress,
            phoneNumber: phoneNumber,
            items: items,
            status: status
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(_):
                    self.showSuccessfullyOrderSheet = true
                    SBUserDefaultService.instance.clearCart()
                    completion(true, nil)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false, error.localizedDescription)
                }
            }
        }
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
    PaymentMethod(name: "PayPal", subtitle: "Platform Payment", color: .orange, imageName: "img_paypal"),
    PaymentMethod(name: "COD", subtitle: "Cash On Delivery", color: .green, imageName: "img_COD")
    ]
