import Foundation

extension SBProduct {
    static var sample: SBProduct {
        SBProduct.init(id: 1, sellerId: "1", name: "1", description: "1", basePrice: 1.0, status: 1, categoryId: 1, quantity: 1, createdAt: "", updatedAt: "", productImages: [], productVariants: [], listTag: [])
    }

    static var sample2: SBProduct {
        SBProduct.init(id: 1, sellerId: "1", name: "1", description: "1", basePrice: 1.0, status: 1, categoryId: 1, quantity: 1, createdAt: "", updatedAt: "", productImages: [], productVariants: [], listTag: [])
    }
    static var sample3: SBProduct {
        SBProduct.init(id: 1, sellerId: "1", name: "1", description: "1", basePrice: 1.0, status: 1, categoryId: 1, quantity: 1, createdAt: "", updatedAt: "", productImages: [], productVariants: [], listTag: [])
    }
    static var sample4: SBProduct {
        SBProduct.init(id: 1, sellerId: "1", name: "1", description: "1", basePrice: 1.0, status: 1, categoryId: 1, quantity: 1, createdAt: "", updatedAt: "", productImages: [], productVariants: [], listTag: [])
    }

    static var sampleList: [SBProduct] {
        [sample, sample2, sample3, sample4]
    }
}
