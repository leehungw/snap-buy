import SwiftUI

struct SBForgotPasswordSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var isEnterNewPasswordPresented: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var temporaryPassword = ""
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text(RLocalizable.forgotPassword())
                    .font(.title)
                    .bold()
                    .padding(.top, 40)
                    .padding(.bottom, 10)
                
                Text(RLocalizable.enterYourEmail())
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(RLocalizable.email())
                        .font(.title3)
                        .bold()
                        .padding(.horizontal, 20)
                }
                SBTextField(image: RImage.img_email.image, placeholder: RLocalizable.enterYourEmail(), text: $email)
            }
            .padding(.bottom, 20)
            
            SBButton(title: RLocalizable.sendCode(), style: .filled) {
                if email.isEmpty {
                    alertMessage = "Please enter your email address"
                    showAlert = true
                    return
                }
                
                isLoading = true
                DispatchQueue.global(qos: .background).async {
                    SBEmailService.shared.sendTemporaryPassword(to: email) { password in
                        DispatchQueue.main.async {
                            isLoading = false
                            if !password.isEmpty {
                                temporaryPassword = password
                                let request = UpdatePasswordRequest(newPassword: password)
                                UserRepository.shared.updatePassword(request: request) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success(let response):
                                            if response.result == 1 {
                                                isEnterNewPasswordPresented = true
                                            } else {
                                                alertMessage = response.error?.message ?? "Failed to update password"
                                                showAlert = true
                                            }
                                        case .failure(let error):
                                            alertMessage = error.localizedDescription
                                            showAlert = true
                                        }
                                    }
                                }
                            } else {
                                alertMessage = "Failed to send temporary password"
                                showAlert = true
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
        .overlay {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Password Reset"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $isEnterNewPasswordPresented, onDismiss: {
            dismiss()
        }) {
            SBForgotPasswordSuccess(temporaryPassword: temporaryPassword)
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(50)
        }
    }
}

struct SBForgotPasswordSuccess: View {
    @Environment(\.dismiss) private var dismissSuccess
    let temporaryPassword: String
    
    var body: some View {
        VStack(spacing: 24) {
            RImage.img_email_verification.image
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 32)
            
            Text("A temporary password has been sent to your email.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Text("Your temporary password is: \(temporaryPassword)")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Text("Please use this password to log in and change it immediately for security reasons.")
                .font(.callout)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            SBButton(title: "Got It", style: .filled) {
                dismissSuccess()
            }
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}

#Preview {
    SBForgotPasswordSuccess(temporaryPassword: "temp123")
}
