import SwiftUI

struct SBSignUpView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text(RLocalizable.createAccount())
                        .font(.title)
                        .bold()
                        .padding(.top, 20)
                    
                    Text(RLocalizable.startShoppingWithRegisteredAccount())
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(RLocalizable.username())
                        .font(.title3)
                        .bold()
                        .padding(.horizontal, 20)
                    SBTextField(image: RImage.img_user.image, placeholder: RLocalizable.createYourUsername(), text: $username)
                }
                
                VStack(alignment: .leading, spacing:  5) {
                    HStack {
                        Text(RLocalizable.email())
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 20)
                    }
                    SBTextField(image: RImage.img_email.image, placeholder: RLocalizable.enterYourEmail(), text: $email)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(RLocalizable.password())
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 20)
                    }
                    SBTextField(image: RImage.img_password.image, placeholder: RLocalizable.createYourPassword(), text: $password, isSecure: true)
                }
                
                
                SBButton(title: RLocalizable.createAccount(), style: .filled) {
                    if username.isEmpty || email.isEmpty || password.isEmpty {
                        alertMessage = RLocalizable.yourAccountWillBeCreatedAsSoonAsYouFilledAllTheInformationNeeded()
                        showAlert = true
                    } else {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let keyWindow = windowScene.windows.first {
                            keyWindow.rootViewController = UIHostingController(rootView: SBHomeTabbarView())
                            keyWindow.makeKeyAndVisible()
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(RLocalizable.infoMissing()),
                        message: Text(alertMessage),
                        dismissButton: .default(Text(RLocalizable.oK()))
                    )
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
