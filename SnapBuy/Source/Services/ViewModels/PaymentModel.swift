import SwiftUI
import PayPal

class PaymentViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessfullyOrderSheet = false
    
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
            
            // Here you would typically open this URL in a web view or browser
            // and handle the return URL in your app delegate
            print("Seller should complete onboarding at: \(onboardingUrl)")
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
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
    PaymentMethod(name: "PayPal", subtitle: "Platform Payment", color: .orange, imageName: "img_paypal")
]
