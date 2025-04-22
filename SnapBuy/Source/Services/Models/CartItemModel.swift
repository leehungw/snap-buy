import SwiftUI

struct CartItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let color: String
    let price: Double
    let quantity: Int

    static let cartitems: [CartItem] = [
        CartItem(imageName: "img_1", title: "Bix Bag Limited Edition 229", color: "Berown", price: 67.0, quantity: 1),
        CartItem(imageName: "img_2", title: "Bix Bag Limited Edition 229", color: "Berown", price: 26.0, quantity: 1),
        CartItem(imageName: "img_3", title: "Bix Bag Limited Edition 229", color: "Berown", price: 32.0, quantity: 1),
        CartItem(imageName: "img_1", title: "Bix Bag 319", color: "Berown", price: 24.0, quantity: 1)
    ]
}
