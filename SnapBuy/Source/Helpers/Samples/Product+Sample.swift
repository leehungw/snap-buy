import Foundation

extension SBProduct {
    static var sample: SBProduct {
        SBProduct(
            name: "The Mirac Jiz",
            brand: "Lisa Robber",
            price: 195.00,
            imageName: "img_1"
        )
    }

    static var sample2: SBProduct {
        SBProduct(
            name: "Meriza Kiles",
            brand: "Gazuna Resika",
            price: 143.45,
            imageName: "img_2"
        )
    }
    static var sample3: SBProduct {
        SBProduct(
            name: "Meriza Kiles",
            brand: "Gazuna Resika",
            price: 143.45,
            imageName: "img_3"
        )
    }
    static var sample4: SBProduct {
        SBProduct(
            name: "The Mirac Jiz",
            brand: "Lisa Robber",
            price: 195.00,
            imageName: "img_1"
        )
    }

    static var sampleList: [SBProduct] {
        [sample, sample2, sample3, sample4]
    }
}
