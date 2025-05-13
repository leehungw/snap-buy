import SwiftSMTP
import Foundation

final class SBEmailService {
    static let shared = SBEmailService()
    private let smtp: SMTP
    private let fromUser: Mail.User
    
    private init() {
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
    
    func sendTemporaryPassword(to email: String, completion: @escaping (String) -> Void) {
        let characters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        let tempPassword = String((0..<8).compactMap { _ in characters.randomElement() })
        
        let toUser = Mail.User(email: email)
        let mail = Mail(
            from: fromUser,
            to: [toUser],
            subject: "Your Temporary Password",
            text: "Your temporary password is: \(tempPassword)\nPlease use this to log in and change your password immediately."
        )
        smtp.send(mail) { error in
            if let error = error {
                print("SMTP send error:", error)
            } else {
                print("Temporary password sent to \(email)")
            }
            completion(tempPassword)
        }
    }
}
