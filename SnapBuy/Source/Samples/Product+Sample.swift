import Foundation

extension Product {
    static var sample: Product {
        Product(
            name: "The Mirac Jiz",
            brand: "Lisa Robber",
            price: 195.00,
            imageName: "img_1"
        )
    }

    static var sample2: Product {
        Product(
            name: "Meriza Kiles",
            brand: "Gazuna Resika",
            price: 143.45,
            imageName: "img_2"
        )
    }
    static var sample3: Product {
        Product(
            name: "Meriza Kiles",
            brand: "Gazuna Resika",
            price: 143.45,
            imageName: "img_3"
        )
    }
    static var sample4: Product {
        Product(
            name: "The Mirac Jiz",
            brand: "Lisa Robber",
            price: 195.00,
            imageName: "img_1"
        )
    }

    static var sampleList: [Product] {
        [sample, sample2, sample3, sample4]
    }
}
