import SwiftUI

struct SBForgotPasswordSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var isEnterNewPasswordPresented: Bool = false
    
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
            
            VStack(alignment: .leading, spacing:  5) {
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
                isEnterNewPasswordPresented = true
                DispatchQueue.global(qos: .background).async {
                    EmailService.shared.sendTemporaryPassword(to: email) { password in
                        UserRepository.shared.updatePassword()
                    }
                }
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
        .sheet(isPresented: $isEnterNewPasswordPresented, onDismiss: {
            dismiss()
        }) {
            SBForgotPasswordSuccess()
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(50)
        }
    }
}

struct SBForgotPasswordSuccess: View {
    @Environment(\.dismiss) private var dismissSuccess
    
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
    SBForgotPasswordSuccess()
}
