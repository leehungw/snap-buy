import SwiftUI

struct SBLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(RLocalizable.loginAccount())
                            .font(.title)
                            .bold()
                            .padding(.top, 40)
                            .padding(.bottom, 20)
                        
                        Text(RLocalizable.pleaseLoginWithRegisteredAccount())
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                
                SBTextField(image: RImage.img_email.image, placeholder: RLocalizable.enterYourEmailOrPhoneNumber(), text: $email)
                SBTextField(image: RImage.img_password.image, placeholder: RLocalizable.createYourPassword(), text: $password, isSecure: true)
                
                HStack {
                    Spacer()
                    Text(RLocalizable.forgotPassword())
                        .foregroundColor(.main)
                        .font(.footnote).bold()
                        .padding(.trailing, 20)
                        .padding(.bottom, 40)
                }
                
                
                SBButton(title: RLocalizable.signIn(), style: .filled) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let keyWindow = windowScene.windows.first {
                        keyWindow.rootViewController = UIHostingController(rootView: SBHomeTabbarView())
                        keyWindow.makeKeyAndVisible()
                    }
                }
                
                Text(RLocalizable.orUsingOtherMethod())
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .padding(.top, 10)
                
                VStack(spacing: 10) {
                    SBButton(title: RLocalizable.signInWithGoogle(), leadingIcon: RImage.img_google_icon.image, style: .outlined) {
                        // Google Sign In Action
                    }
                    SBButton(title: RLocalizable.signInWithFacebook(), leadingIcon: RImage.img_facebook_icon.image, style: .outlined) {
                        // Facebook Sign In Action
                    }
                }
            }
        }
        .navigationTitle("")
        .toolbar(.hidden)
    }
}
