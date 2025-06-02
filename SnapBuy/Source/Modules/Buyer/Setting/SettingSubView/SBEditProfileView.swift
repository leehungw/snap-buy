import SwiftUI

struct SBEditProfileView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @StateObject private var userModeManager = UserModeManager.shared
    
    init() {
        if let currentUser = UserRepository.shared.currentUser {
            _username = State(initialValue: currentUser.userName)
            _email = State(initialValue: currentUser.email)
        }
    }
    
    var body: some View {
        SBSettingBaseView(title: "Edit Profile") {
            VStack(spacing: 24) {
                Image("cat_access")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(.top, 20)
                
                if let user = UserRepository.shared.currentUser {
                    if user.isPremium {
                        Button(action: {
                            userModeManager.switchMode()
                        }) {
                            HStack {
                                Image(systemName: userModeManager.currentMode == .seller ? "arrow.left" : "arrow.right")
                                Text(userModeManager.currentMode == .buyer ? "Switch to Seller" : "Switch to Buyer")
                                    .font(R.font.outfitBold.font(size: 16))
                            }
                            .foregroundColor(.main)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.main, lineWidth: 2)
                            )
                        }
                    } else {
                        NavigationLink(destination: SBUpgradeAccountView()) {
                            Text("Upgrade To Seller")
                                .font(R.font.outfitRegular.font(size: 16))
                                .foregroundColor(.white)
                        }
                        .padding(13)
                        .background(Color.main)
                        .cornerRadius(30)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(R.font.outfitSemiBold.font(size: 16))
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.main)
                        TextField("Username", text: $username)
                            .font(R.font.outfitRegular.font(size: 16))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email or Phone Number")
                        .font(R.font.outfitSemiBold.font(size: 16))
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.main)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .font(R.font.outfitRegular.font(size: 16))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Account Liked With")
                        .font(R.font.outfitSemiBold.font(size: 16))
                    HStack {
                        Image("img_google_icon")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.trailing,10)
                        Text("Google")
                            .foregroundColor(.black)
                            .font(R.font.outfitRegular.font(size: 16))
                        Spacer()
                        Image(systemName: "link")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                Spacer()
                
                Button(action: {
                    updateProfile()
                }) {
                    Text("Save Changes")
                        .foregroundColor(.white)
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.main)
                        .cornerRadius(30)
                }
            }
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Profile Update"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func updateProfile() {
        isLoading = true
        let request = UpdateProfileRequest(userName: username, email: email)
        UserRepository.shared.updateProfile(request: request) { result in
            isLoading = false
            switch result {
            case .success(let response):
                if response.result == 1 {
                    alertMessage = "Profile updated successfully"
                } else {
                    alertMessage = response.error?.message ?? "Failed to update profile"
                }
            case .failure(let error):
                alertMessage = error.localizedDescription
            }
            showAlert = true
        }
    }
}
#Preview {
    SBEditProfileView()
}
