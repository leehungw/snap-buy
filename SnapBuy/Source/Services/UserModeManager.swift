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
            
            if let merchantId = user.sellerMerchantId {
                let status = try await SBPaypalService.shared.checkSellerStatus(sellerMerchantId: merchantId)
                if status.isFullyOnboarded {
                    isPayPalConnected = true
                    self.merchantId = merchantId
                    isOnboardingPayPal = false
                    return
                }
            }
            
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
              permissionsGranted == "true",
              let userId = UserRepository.shared.currentUser?.id else {
            onboardingError = "PayPal connection failed"
            return
        }
        
        // Update the merchant ID in our backend
        UserRepository.shared.updateMerchantId(userId: userId, merchantId: merchantIdParam) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.result == 1 {
                    // Store the merchant ID locally
                    self.merchantId = merchantIdParam
                    // Clear the onboarding URL since we're now connected
                    self.paypalOnboardingURL = nil
                    self.isPayPalConnected = true
                    
                    // Verify the connection
                    Task {
                        await self.checkPayPalOnboarding()
                    }
                } else {
                    self.onboardingError = response.error?.message ?? "Failed to update merchant ID"
                }
            case .failure(let error):
                self.onboardingError = error.localizedDescription
            }
        }
    }
} 
