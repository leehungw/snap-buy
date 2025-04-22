import SwiftUI

struct SBLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isForgotPasswordPresented: Bool = false

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
                    SBTextField(image: RImage.img_password.image, placeholder: RLocalizable.createYourPassword(), text: $password, isSecure: true)
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
//                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                       let keyWindow = windowScene.windows.first {
//                        keyWindow.rootViewController = UIHostingController(rootView: SBHomeTabbarView())
//                        keyWindow.makeKeyAndVisible()
//                    }
                    let loginRequest = UserLoginRequest(email: "ndam8175@gmail.com", password: "123123")
                    UserRepository.shared.login(request: loginRequest) { result in
                        switch result {
                        case .success(let response):
                            if response.result == 1, let userData = response.data {
                                print("Login successful! User ID: \(userData.id), Name: \(userData.name)")
                            } else if let errorInfo = response.error {
                                print("Login failed: \(errorInfo.message)")
                            } else {
                                print("Unexpected response structure.")
                            }
                        case .failure(let error):
                            print("Request failed with error: \(error.localizedDescription)")
                        }
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
        .sheet(isPresented: $isForgotPasswordPresented) {
            SBForgotPasswordSheetView()
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(50)
        }
    }
    
    private func forgotPassword() {
        isForgotPasswordPresented = true
    }
}

#Preview {
    SBLoginView()
}
