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
    @State private var isLoading: Bool = false

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
                        isLoading = true
                        let request = SignUpRequest(userName: username, email: email, password: password)
                        UserRepository.shared.signUp(request: request) { result in
                            DispatchQueue.main.async {
                                isLoading = false
                                switch result {
                                case .success(let response):
                                    if response.result == 1 {
                                        //
                                    } else {
                                        alertMessage = response.error?.message ?? "Sign up failed"
                                        showAlert = true
                                    }
                                case .failure(let error):
                                    alertMessage = error.localizedDescription
                                    showAlert = true
                                }
                            }
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
                SBSignUpWithGoogleButton {
                    message in
                    alertMessage = message
                    showAlert = true
                }
            }
        }
        .navigationTitle("")
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
        .overlay {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
        }
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
