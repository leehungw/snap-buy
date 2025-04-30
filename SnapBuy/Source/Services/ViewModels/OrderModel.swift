import SwiftUI

struct Order: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let color: String
    let quantity: Int
    let price: Double
    let status: String
}
let orders: [Order] = [
    Order(title: "Bix Bag Limited Edition 229", imageName: "bag1", color: "Berown", quantity: 1, price: 24.00, status: "On Progress"),
    Order(title: "Bix Bag 319", imageName: "bag2", color: "Berown", quantity: 1, price: 21.50, status: "Pending")
]


struct Purchased: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let color: String
    let quantity: Int
    let price: Double
    let status: String
}
let purchased: [Purchased] = [
    Purchased(title: "Bix Bag Limited Edition 229", imageName: "bag1", color: "Berown", quantity: 1, price: 24.00, status: "Complete"),
    Purchased(title: "Bix Bag 319", imageName: "bag2", color: "Berown", quantity: 1, price: 21.50, status: "Cancel")
]
