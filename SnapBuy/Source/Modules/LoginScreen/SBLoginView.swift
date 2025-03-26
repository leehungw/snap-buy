import SwiftUI

struct SBLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(RLocalizable.loginAccount())
                .font(.title)
                .bold()
                .padding(.top, 40)

            Text(RLocalizable.pleaseLoginWithRegisteredAccount())
                .foregroundColor(.gray)
                .font(.subheadline)

            SBTextField(image: Image("a"), placeholder: RLocalizable.enterYourEmailOrPhoneNumber(), text: $email)
            SBTextField(image: Image("lock"), placeholder: RLocalizable.createYourPassword(), text: $password, isSecure: true)

            HStack {
                Spacer()
                Text(RLocalizable.forgotPassword())
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .padding(.trailing, 20)
            }

            SBButton(title: RLocalizable.signIn(), style: .filled) {
                // Handle Sign In Action
            }
            
            Text("Or using other method")
                .foregroundColor(.gray)
                .font(.footnote)
                .padding(.top, 10)
            
            VStack(spacing: 10) {
                SBButton(title: "Sign In with Google", leadingIcon: Image("globe"), style: .outlined) {
                    // Google Sign In Action
                }
                SBButton(title: "Sign In with Facebook", leadingIcon: Image("person.2.fill"), style: .outlined) {
                    // Facebook Sign In Action
                }
            }
        }
    }
}
