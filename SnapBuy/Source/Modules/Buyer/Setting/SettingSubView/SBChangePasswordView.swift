import SwiftUI

struct SBChangePasswordView: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        SBSettingBaseView(title: "Change Password") {
            VStack(spacing: 24) {
                // New Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("New Password")
                        .font(R.font.outfitSemiBold.font(size: 16))
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        
                        if isPasswordVisible {
                            TextField("Enter new password", text: $password)
                                .font(R.font.outfitRegular.font(size: 16))
                        } else {
                            SecureField("Enter new password", text: $password)
                                .font(R.font.outfitRegular.font(size: 16))
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .foregroundColor(isPasswordVisible ? .main : .gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                
                // Confirm Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(R.font.outfitSemiBold.font(size: 16))
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        
                        if isConfirmPasswordVisible {
                            TextField("Confirm your new password", text: $confirmPassword)
                                .font(R.font.outfitRegular.font(size: 16))
                        } else {
                            SecureField("Confirm your new password", text: $confirmPassword)
                                .font(R.font.outfitRegular.font(size: 16))
                        }
                        
                        Button(action: {
                            isConfirmPasswordVisible.toggle()
                        }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye" : "eye.slash")
                                .foregroundColor(isConfirmPasswordVisible ? .main : .gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                
                Spacer()
                
                Button(action: {
                    updatePassword()
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Password Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
            }
            .padding(.vertical,20)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func updatePassword() {
        if password.isEmpty || confirmPassword.isEmpty {
            alertMessage = "Please fill in both fields."
            showAlert = true
            return
        }
        
        if password != confirmPassword {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }
        
        isLoading = true
        let request = UpdatePasswordRequest(newPassword: password)
        UserRepository.shared.updatePassword(request: request) { result in
            isLoading = false
            switch result {
            case .success(let response):
                if response.result == 1 {
                    alertMessage = "Password updated successfully"
                } else {
                    alertMessage = response.error?.message ?? "Failed to update password"
                }
            case .failure(let error):
                alertMessage = error.localizedDescription
            }
            showAlert = true
        }
    }
}

#Preview {
    SBChangePasswordView()
}
