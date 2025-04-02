import SwiftUI

struct SBVerificationView: View {
    enum FocusField: Hashable {
        case code1, code2, code3, code4, code5
    }

    @FocusState private var focusField: FocusField?
    
    @State private var code1: String = ""
    @State private var code2: String = ""
    @State private var code3: String = ""
    @State private var code4: String = ""
    @State private var code5: String = ""
    
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
                
                Text(RLocalizable.weHaveSentTheCodeVerificationTo("hungtat@gmail.com"))
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
                        focusField = nil
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
                    //TODO: submit
                })
                
                Button(action: {
                    // Handle resend action
                }) {
                    createAttributedText()
                }
                .padding(.top, 16)
                
                Spacer()
            }
        }
        .navigationTitle("")
        .toolbar(.hidden)
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

#Preview {
    SBVerificationView()
}
