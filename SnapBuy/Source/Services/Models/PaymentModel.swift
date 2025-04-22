import SwiftUI

struct PaymentMethod: Identifiable {
    var id = UUID()
    var name: String
    var subtitle: String
    var color: Color
    let imageName: String
}

let paymentMethods: [PaymentMethod] = [
    PaymentMethod(name: "Credit Card", subtitle: "Visa **** 1234", color: .blue, imageName: "img_ccard"),
        PaymentMethod(name: "PayPal", subtitle: "user@example.com", color: .orange, imageName: "img_paypal"),
        PaymentMethod(name: "COD", subtitle: "Cash on Delivery", color: .black, imageName: "img_COD")
    ]
