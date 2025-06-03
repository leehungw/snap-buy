import SwiftUI

struct SBSellerProfileView: View {
    @StateObject private var userModeManager = UserModeManager.shared
    @State private var showPayPalOnboarding = false
    
    var body: some View {
        VStack {
            // Show PayPal onboarding sheet if URL is available
            .sheet(isPresented: $showPayPalOnboarding) {
                SBPayPalOnboardingView()
            }
        }
        .onAppear {
            // Show PayPal onboarding if we have a URL and user is premium
            if userModeManager.paypalOnboardingURL != nil,
               let user = UserRepository.shared.currentUser,
               user.isPremium {
                showPayPalOnboarding = true
            }
        }
    }
} 