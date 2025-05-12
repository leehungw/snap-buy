import SwiftUI
import Foundation
import SwiftSMTP

struct SBVerificationView: View {
    let username: String
    let email: String
    let password: String
    enum FocusField: Hashable {
        case code1, code2, code3, code4, code5
    }
    
    @FocusState private var focusField: FocusField?
    
    @State private var code1: String = ""
    @State private var code2: String = ""
    @State private var code3: String = ""
    @State private var code4: String = ""
    @State private var code5: String = ""
    @State var generatedCode: String
    @State private var isLoading: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    @State private var isSheetPresented: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                ZStack {
                    RImage.img_email_verification.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                
                Text(RLocalizable.verificationCode())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 24)
                
                Text(RLocalizable.weHaveSentTheCodeVerificationTo(email))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                
                HStack(spacing: 16) {
                    SBEmailVerificationTextView(text: $code1) {
                        focusField = .code2
                    }
                    .focused($focusField, equals: .code1)
                    
                    SBEmailVerificationTextView(text: $code2) {
                        focusField = .code3
                    }
                    .focused($focusField, equals: .code2)
                    
                    SBEmailVerificationTextView(text: $code3) {
                        focusField = .code4
                    }
                    .focused($focusField, equals: .code3)
                    
                    SBEmailVerificationTextView(text: $code4) {
                        focusField = .code5
                    }
                    .focused($focusField, equals: .code4)
                    
                    SBEmailVerificationTextView(text: $code5) {
                        focusField = nil
                    }
                    .focused($focusField, equals: .code5)
                }
                .padding(.top, 24)
                .padding(.bottom, 30)
                
                SBButton(title: RLocalizable.submit(), style: .filled, action: {
                    let entered = code1 + code2 + code3 + code4 + code5
                    guard entered == generatedCode else {
                        alertMessage = "Verification code is incorrect"
                        showAlert = true
                        return
                    }
                    isLoading = true
                    let request = SignUpRequest(userName: username, email: email, password: password)
                    UserRepository.shared.signUp(request: request) { result in
                        DispatchQueue.main.async {
                            isLoading = false
                            switch result {
                            case .success(let response):
                                if response.result == 1 {
                                    isSheetPresented = true
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
                })
                
                Button(action: {
                    Task {
                        generatedCode = (0..<5).map { _ in String(Int.random(in: 0...9)) }.joined()
                        await withCheckedContinuation { continuation in
                            EmailService.shared.sendVerificationCode(to: email, code: generatedCode) {
                                continuation.resume()
                            }
                        }
                    }
                }) {
                    createAttributedText()
                }
                .padding(.top, 16)
                
                Spacer()
            }
        }
        .navigationTitle("")
        .toolbar(.hidden)
        .sheet(isPresented: $isSheetPresented) {
            VStack {
                SBRegisterSuccessView()
            }
            .presentationDetents([.fraction(0.5)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(50)
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(RLocalizable.infoMissing()),
                message: Text(alertMessage),
                dismissButton: .default(Text(RLocalizable.oK()))
            )
        }
    }
    
    private func createAttributedText() -> Text {
        let baseString = NSAttributedString(string: RLocalizable.didnTReceiveTheCode(), attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.black])
        let resendString = NSAttributedString(string: RLocalizable.resend(), attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.main])
        let attributedString = NSMutableAttributedString()
        attributedString.append(baseString)
        attributedString.append(resendString)
        return Text(.init(attributedString))
    }
}

struct SBRegisterSuccessView: View {
    var body: some View {
        NavigationView {
            VStack {
                RImage.img_success_check.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding(.top, 30)
                
                Text(RLocalizable.registerSuccess())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 16)
                
                Text(RLocalizable.congratulationYourAccountAlreadyCreatedPleaseLoginToGetAmazingExperience())
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.bottom, 80)
                
                SBButton(title: RLocalizable.goToHomepage(), style: .filled) {
                    
                }
            }
        }
        .navigationTitle("")
        .toolbar(.hidden)
    }
}

final class EmailService {
    static let shared = EmailService()
    private let smtp: SMTP
    private let fromUser: Mail.User

    private init() {
        // Configure your SMTP server credentials
        smtp = SMTP(
            hostname: "smtp.gmail.com",
            email: "hungttalop61@gmail.com",
            password: "qbiz bkgx vrpq wjwv",
            port: 587,
            tlsMode: .requireSTARTTLS,
            authMethods: [.plain]
        )
        fromUser = Mail.User(name: "Snap Buy", email: "hungttalop61@gmail.com")
    }

    func sendVerificationCode(to email: String, code: String, completion: @escaping () -> Void) {
        let toUser = Mail.User(email: email)
        let mail = Mail(
            from: fromUser,
            to: [toUser],
            subject: "Your Verification Code",
            text: "Your verification code for SnapBuy is \(code)"
        )
        smtp.send(mail) { error in
            if let error = error {
                print("SMTP send error:", error)
                completion()
            } else {
                print("Verification email sent to \(email)")
                completion()
            }
        }
    }
}
