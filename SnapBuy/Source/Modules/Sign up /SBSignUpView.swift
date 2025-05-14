import SwiftUI
import UIKit
import GoogleSignIn


struct SBSignUpView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToVerification = false
    @State private var generatedCode: String = ""

    var body: some View {
        let navigationView = NavigationView {
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
                        generatedCode = (0..<5).map { _ in String(Int.random(in: 0...9)) }.joined()
                        DispatchQueue.global(qos: .background).async {
                            EmailService.shared.sendVerificationCode(to: email, code: generatedCode) {
                                // optional completion
                            }
                        }
                        navigateToVerification = true
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(RLocalizable.infoMissing()),
                        message: Text(alertMessage),
                        dismissButton: .default(Text(RLocalizable.oK()))
                    )
                }
                
                NavigationLink(destination: SBVerificationView(username: username, email: email, password: password, generatedCode: generatedCode), isActive: $navigateToVerification) {
                    EmptyView()
                }
                
                Text(RLocalizable.orUsingOtherMethod())
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .padding(.top, 10)
                SBSignUpWithGoogleButton {
                    message in
                    alertMessage = message
                    showAlert = true
                }
            }
        }
        return navigationView.navigationTitle("")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
    }
    
    private func showAlert(message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        rootVC.present(alert, animated: true)
    }
}
struct SBSignUpWithGoogleButton: View {
    var showAlert: (String) -> Void

    var body: some View {
        SBButton(title: RLocalizable.signInWithGoogle(), leadingIcon: RImage.img_google_icon.image, style: .outlined) {
            guard let windowScene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let root = windowScene.windows.first?.rootViewController else {
                return
            }

            GIDSignIn.sharedInstance.signIn(withPresenting: root) { signInResult, error in
                guard let signInResult else { return }

                signInResult.user.refreshTokensIfNeeded { user, error in
                    guard error == nil else {
                        showAlert("Google sign-in failed.")
                        return
                    }
                    guard let user = user else { return }

                    let idTokenString = user.idToken?.tokenString ?? ""
                    let email = user.profile?.email ?? ""

                    let googleRequest = GoogleLoginRequest(googleId: idTokenString, email: email)
                    UserRepository.shared.loginWithGoogle(request: googleRequest) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                                if response.result == 1 {
                                    if let windowScene = UIApplication.shared.connectedScenes
                                        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                                       let keyWindow = windowScene.windows.first {
                                        keyWindow.rootViewController = UIHostingController(rootView: SBHomeTabbarView())
                                        keyWindow.makeKeyAndVisible()
                                    }
                                } else if let errorInfo = response.error {
                                    showAlert(errorInfo.message)
                                }
                            case .failure(let error):
                                showAlert(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }
}
#Preview {
    SBSignUpView()
}
