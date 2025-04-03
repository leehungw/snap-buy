import SwiftUI

struct SBForgotPasswordSheetView: View {
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
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
        .sheet(isPresented: $isEnterNewPasswordPresented) {
            SBEnterNewPasswordSheetView()
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(50)
        }
    }
}

struct SBEnterNewPasswordSheetView: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text(RLocalizable.createNewPassword())
                    .font(.title)
                    .bold()
                    .padding(.top, 40)
                    .padding(.bottom, 10)
                
                Text(RLocalizable.enterYourNewPassword())
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing:  5) {
                HStack {
                    Text(RLocalizable.password())
                        .font(.title3)
                        .bold()
                        .padding(.horizontal, 20)
                }
                SBTextField(image: RImage.img_password.image, placeholder: RLocalizable.enterYourPassword(), text: $password)
            }
            .padding(.bottom, 5)
            
            VStack(alignment: .leading, spacing:  5) {
                HStack {
                    Text(RLocalizable.confirmPassword())
                        .font(.title3)
                        .bold()
                        .padding(.horizontal, 20)
                }
                SBTextField(image: RImage.img_password.image, placeholder: RLocalizable.confirmPassword(), text: $confirmPassword)
            }
            .padding(.bottom, 20)
            
            SBButton(title: RLocalizable.changePassword(), style: .filled) {
                 
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
    }
}

#Preview {
    SBEnterNewPasswordSheetView()
}
