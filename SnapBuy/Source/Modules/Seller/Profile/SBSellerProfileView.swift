import SwiftUI
import UIKit

struct SBSellerProfileView: View {
    @StateObject private var userModeManager = UserModeManager.shared
    @State private var showPayPalOnboarding = false
    @State private var user: UserData? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView{
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Text("Profile")
                        .font(R.font.outfitMedium.font(size: 20))
                        .foregroundColor(.white)
                        .padding(.leading,20)
                    Spacer()
                    NavigationLink(destination: SBSellerSettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(Color.white)
                    }
                }
                .padding()
                .background(Color.main)
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if let user = user {
                    if let imageURL = URL(string: user.imageURL) {
                        AsyncImage(url: imageURL) { image in
                            image.resizable()
                        } placeholder: {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    }
                    Text(user.name)
                        .font(.custom("Outfit-Medium", size: 24))
                        .fontWeight(.bold)
                    Text("@\(user.userName)")
                        .font(.custom("Outfit-Regular", size: 16))
                        .foregroundColor(.secondary)
                    Text(user.email)
                        .font(.custom("Outfit-Regular", size: 16))
                        .foregroundColor(.secondary)
                    
                    // Switch to Buyer Mode Button
                    Button(action: {
                        UserModeManager.shared.switchMode()
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Switch to Buyer Mode")
                                .font(R.font.outfitBold.font(size: 16))
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(20)
                    }
                    .padding(.vertical, 8)

                    // PayPal Onboarding Button
                    if user.sellerMerchantId == nil || user.sellerMerchantId?.isEmpty == true {
                        Button(action: {
                            showPayPalOnboarding = true
                        }) {
                            HStack {
                                Image("img_paypal")
                                    .resizable()
                                    .frame(width: 32, height: 24)
                                Text("Setup PayPal Onboarding")
                                    .font(R.font.outfitBold.font(size: 16))
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.main)
                            .cornerRadius(20)
                        }
                    }
                }
                Spacer()
                Button(action: handleLogout) {
                    Text("Log Out")
                        .font(R.font.outfitBold.font(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    UserRepository.shared.logout()
                    // Navigate to login screen
                    DispatchQueue.main.async {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let keyWindow = windowScene.windows.first {
                            let loginView = SBLoginView(shouldShowBackButton: false)
                            let hostingController = UIHostingController(rootView: loginView)
                            keyWindow.rootViewController = hostingController
                            keyWindow.makeKeyAndVisible()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .sheet(isPresented: $showPayPalOnboarding) {
                SBPayPalOnboardingView()
            }
            .onAppear {
                fetchUser()
            }
        }
    }
    
    private func fetchUser() {
        guard let userId = UserRepository.shared.currentUser?.id else {
            self.errorMessage = "User not logged in"
            return
        }
        isLoading = true
        errorMessage = nil
        UserRepository.shared.fetchUserById(userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let userData):
                    self.user = userData
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    private func handleLogout() {
        showLogoutAlert = true
    }
}
 
