import SwiftUI

struct CartItem: Identifiable {
    let id = UUID()
    let imageName: String // This will now store either a local image name or URL string
    let title: String
    let color: String
    let size: String
    let price: Double
    let quantity: Int
}

// Example items for preview
extension CartItem {
    static let cartitems: [CartItem] = [
        CartItem(imageName: "img_1", title: "Bix Bag Limited Edition 229", color: "#8B4513", size: "M", price: 67.0, quantity: 1),
        CartItem(imageName: "img_2", title: "Bix Bag Limited Edition 229", color: "#8B4513", size: "L", price: 26.0, quantity: 1),
        CartItem(imageName: "img_3", title: "Bix Bag Limited Edition 229", color: "#8B4513", size: "XL", price: 32.0, quantity: 1),
        CartItem(imageName: "img_1", title: "Bix Bag 319", color: "#8B4513", size: "S", price: 24.0, quantity: 1)
    ]
}
