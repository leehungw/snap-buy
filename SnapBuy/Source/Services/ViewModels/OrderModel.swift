import SwiftUI

enum OrderStatus: String, CaseIterable, Identifiable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case complete = "Complete"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
    var id: String { self.rawValue }
}
struct BuyerInfo {
    var name: String
    var address: String
    var phone: String
}



struct OrderItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let color: String
    let quantity: Int
    let price: Double
}

struct sellerOrder: Identifiable {
    let id = UUID()
    let items: [OrderItem]
    let buyer: BuyerInfo
    var status: OrderStatus
}

extension sellerOrder {
    static let sample: [sellerOrder] = [
        sellerOrder(
            items: [
                OrderItem(title: "Bix Bag Limited Edition 229", imageName: "bag1", color: "Brown", quantity: 1, price: 24.00),
                OrderItem(title: "Bix Wallet", imageName: "wallet1", color: "Black", quantity: 2, price: 12.50)
            ],
            buyer: BuyerInfo(
                name: "Alice Nguyen",
                address: "123 Tran Hung Dao, District 1, HCMC",
                phone: "0909 123 456"
            ),
            status: .inProgress
        ),
        sellerOrder(
            items: [
                OrderItem(title: "Bix Bag 319", imageName: "bag2", color: "Brown", quantity: 1, price: 21.50)
            ],
            buyer: BuyerInfo(
                name: "David Pham",
                address: "456 Nguyen Trai, District 5, HCMC",
                phone: "0912 456 789"
            ),
            status: .pending
        )
    ]
}

struct Order: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let color: String
    let quantity: Int
    let price: Double
    let status: OrderStatus
}
let orders: [Order] = [
    Order(title: "Bix Bag Limited Edition 229", imageName: "bag1", color: "Berown", quantity: 1, price: 24.00, status: .inProgress),
    Order(title: "Bix Bag 319", imageName: "bag2", color: "Berown", quantity: 1, price: 21.50, status: .pending)
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
    Purchased(title: "Bix Bag Limited Edition 229", imageName: "cat_access", color: "Berown", quantity: 1, price: 24.00, status: "Complete"),
    Purchased(title: "Bix Bag 319", imageName: "bag2", color: "Berown", quantity: 1, price: 21.50, status: "Cancel")
]
