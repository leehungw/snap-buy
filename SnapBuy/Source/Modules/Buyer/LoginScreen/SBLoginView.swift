import SwiftUI
import GoogleSignInSwift
import GoogleSignIn
import UIKit

struct SBLoginView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isForgotPasswordPresented: Bool = false
    @State var path = NavigationPath()
    @State var shouldShowBackButton: Bool = true

    init(shouldShowBackButton: Bool = true) {
        self.shouldShowBackButton = shouldShowBackButton
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text(RLocalizable.loginAccount())
                        .font(.title)
                        .bold()
                        .padding(.top, 40)
                        .padding(.bottom, 10)
                    
                    Text(RLocalizable.pleaseLoginWithRegisteredAccount())
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
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(RLocalizable.password())
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 20)
                    }
                    SBTextField(image: RImage.img_password.image, placeholder: RLocalizable.enterYourPassword(), text: $password, isSecure: true)
                }
                
                HStack {
                    Spacer()
                    Text(RLocalizable.forgotPassword())
                        .foregroundColor(.main)
                        .font(.footnote).bold()
                        .padding(.trailing, 20)
                        .padding(.bottom, 40)
                        .onTapGesture {
                            forgotPassword()
                        }
                }
                
                
                SBButton(title: RLocalizable.signIn(), style: .filled) {
                    let loginRequest = UserLoginRequest(email: email, password: password)
                    UserRepository.shared.login(request: loginRequest) { result in
                        switch result {
                        case .success(let response):
                            DispatchQueue.main.async {
                                if response.result == 1, let userData = response.data {
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let keyWindow = windowScene.windows.first {
                                        if userData.isAdmin {
                                            keyWindow.rootViewController = UIHostingController(rootView: SBAdminDashboardView())
                                        } else {
                                            keyWindow.rootViewController = UIHostingController(rootView: SBHomeTabbarView())
                                        }
                                        keyWindow.makeKeyAndVisible()
                                    
                                    }
                                } else if let errorInfo = response.error {
                                    showAlert(message: errorInfo.message)
                                } else {
                                    showAlert(message: "Unexpected response structure.")
                                }
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                showAlert(message: error.localizedDescription)
                            }
                        }
                    }
                    
                    
                    
//                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                       let keyWindow = windowScene.windows.first {
//                        keyWindow.rootViewController = UIHostingController(rootView: SBHomeTabbarView())
//                        keyWindow.makeKeyAndVisible()
//                    }
                }
                
                Text(RLocalizable.orUsingOtherMethod())
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .padding(.top, 10)
                
                VStack(spacing: 10) {
                    SBButton(title: RLocalizable.signInWithGoogle(), leadingIcon: RImage.img_google_icon.image, style: .outlined) {
                        guard let windowScene = UIApplication.shared.connectedScenes
                                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                              let root = windowScene.windows.first?.rootViewController else {
                            return
                        }
                        GIDSignIn.sharedInstance.signIn(
                            withPresenting: root) { signInResult, error in
                                guard let signInResult else { return }
                                signInResult.user.refreshTokensIfNeeded { user, error in
                                    guard error == nil else { return }
                                    guard let user = user else { return }
                                    
                                    let idTokenString = user.idToken?.tokenString ?? ""
                                    let email = user.profile?.email ?? ""

                                    let googleRequest = GoogleLoginRequest(googleId: idTokenString, email: email)
                                    UserRepository.shared.loginWithGoogle(request: googleRequest) { result in
                                        switch result {
                                        case .success(let response):
                                            DispatchQueue.main.async {
                                                if response.result == 1, let userData = response.data {
                                                    if let windowScene = UIApplication.shared.connectedScenes
                                                            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                                                       let keyWindow = windowScene.windows.first {
                                                        keyWindow.rootViewController = UIHostingController(rootView: SBHomeTabbarView())
                                                        keyWindow.makeKeyAndVisible()
                                                    }
                                                } else if let errorInfo = response.error {
                                                    showAlert(message: errorInfo.message)
                                                }
                                            }
                                        case .failure(let error):
                                            DispatchQueue.main.async {
                                                showAlert(message: error.localizedDescription)
                                            }
                                        }
                                    }
                                    
                                }
                            }
                    }
                    
                    if shouldShowBackButton {
                        NavigationLink(destination: SBSignUpView()) {
                            Text("Don't have account? Sign Up")
                                .foregroundColor(.main)
                                .font(.subheadline)
                                .bold()
                                .contentShape(Rectangle())
                                .padding(.top, 10)
                        }
                    }
                }
            }
            .sheet(isPresented: $isForgotPasswordPresented) {
                SBForgotPasswordSheetView()
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(50)
            }
        }
        .navigationTitle("")
        .toolbar {
            if shouldShowBackButton {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func forgotPassword() {
        isForgotPasswordPresented = true
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

#Preview {
    SBLoginView()
}
