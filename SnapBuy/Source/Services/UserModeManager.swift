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
            
            let onboardingUrl = try await SBPaypalService.shared.onboardSeller(
                sellerId: user.id,
                email: user.email,
                businessName: user.name
            )
            
            paypalOnboardingURL = onboardingUrl
        } catch {
            onboardingError = error.localizedDescription
        }
        isOnboardingPayPal = false
    }
} 
