import SwiftUI

struct PaymentMethod: Identifiable {
    var id = UUID()
    var name: String
    var subtitle: String
    var color: Color
    let imageName: String
}

let paymentMethods: [PaymentMethod] = [
    PaymentMethod(name: "COD", subtitle: "Cash on Delivery", color: .black, imageName: "img_COD"),
    PaymentMethod(name: "PayPal", subtitle: "user@example.com", color: .orange, imageName: "img_paypal")
]
