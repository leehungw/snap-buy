import Foundation
import Combine
import PayPal

enum UserMode {
    case buyer
    case seller
}

@MainActor
final class UserModeManager: ObservableObject {
    static let shared = UserModeManager()
    
    @Published private(set) var currentMode: UserMode
    @Published var isOnboardingPayPal = false
    @Published var paypalOnboardingURL: String?
    @Published var onboardingError: String?
    @Published var isPayPalConnected = false
    @Published var merchantId: String?
    
    private init() {
        // Check if user is premium and set initial mode
        if let user = UserRepository.shared.currentUser, user.isPremium {
            currentMode = .seller
            // Check for PayPal onboarding when initializing as seller
            Task {
                await checkPayPalOnboarding()
            }
        } else {
            currentMode = .buyer
        }
    }
    
    func switchMode() {
        guard let user = UserRepository.shared.currentUser, user.isPremium else {
            currentMode = .buyer
            return
        }
        
        currentMode = currentMode == .buyer ? .seller : .buyer
        
        // If switching to seller mode, check PayPal onboarding
        if currentMode == .seller {
            Task {
                await checkPayPalOnboarding()
            }
        }
    }
    
    private func checkPayPalOnboarding() async {
        guard let user = UserRepository.shared.currentUser,
              user.isPremium else { return }
        
        do {
            isOnboardingPayPal = true
            onboardingError = nil
            
            // First check if we have a stored merchant ID
            if let merchantId = merchantId {
                // Check the status of the existing connection
                let status = try await SBPaypalService.shared.checkSellerStatus(sellerMerchantId: merchantId)
                if status.isFullyOnboarded {
                    isPayPalConnected = true
                    isOnboardingPayPal = false
                    return
                }
            }
            
            // If not connected, get a new onboarding URL
            let onboardingUrl = try await SBPaypalService.shared.onboardSeller(
                sellerId: user.id,
                email: user.email,
                businessName: user.name
            )
            
            paypalOnboardingURL = onboardingUrl
            isPayPalConnected = false
        } catch {
            onboardingError = error.localizedDescription
            isPayPalConnected = false
        }
        isOnboardingPayPal = false
    }
    
    func handlePayPalReturn(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let merchantIdParam = components.queryItems?.first(where: { $0.name == "merchantIdInPayPal" })?.value,
              let permissionsGranted = components.queryItems?.first(where: { $0.name == "permissionsGranted" })?.value,
              permissionsGranted == "true" else {
            onboardingError = "PayPal connection failed"
            return
        }
        
        // Store the merchant ID
        merchantId = merchantIdParam
        
        // Clear the onboarding URL since we're now connected
        paypalOnboardingURL = nil
        isPayPalConnected = true
        
        // Verify the connection
        Task {
            await checkPayPalOnboarding()
        }
    }
} 
