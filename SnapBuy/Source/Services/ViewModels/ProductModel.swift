import Foundation

struct Product: Identifiable {
    let id: UUID
    var name: String
    var brand: String
    var price: Double
    var stock: Int
    var imageNames: [String]
    var category: String
    var colors: [String]
    var sizes: [String]
    var description: String

    init(
        id: UUID = UUID(),
        name: String,
        brand: String,
        price: Double,
        stock: Int,
        imageNames: [String],
        category: String,
        colors: [String] = [],
        sizes: [String] = [],
        description: String
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.price = price
        self.stock = stock
        self.imageNames = imageNames
        self.category = category
        self.colors = colors
        self.sizes = sizes
        self.description = description
    }

    static let sampleList: [Product] = [
        Product(
            name: "Shoe",
            brand: "Nike",
            price: 99.99,
            stock: 10,
            imageNames: ["cat_shoes"],
            category: "Shoes",
            colors: ["Red", "Black"],
            sizes: ["M", "L"],
            description: "nkasndnjsa"
        ),
        Product(
            name: "Hat",
            brand: "Adidas",
            price: 49.99,
            stock: 5,
            imageNames: ["cat_access"],
            category: "Accessories",
            colors: ["White"],
            sizes: ["Free Size"],
            description: "nkasndnjsa"
        )
    ]
}
