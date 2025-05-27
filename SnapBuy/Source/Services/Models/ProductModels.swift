import Foundation

struct SBProductImage: Codable {
    let id: Int
    let productId: Int
    let url: String
    let isThumbnail: Bool
    let createdAt: String
}

struct SBProductVariant: Codable {
    let id: Int
    let productId: Int
    let size: String
    let color: String
    let price: Double
    let status: Int
    let createdAt: String
}

struct SBProduct: Codable, Identifiable {
    let id: Int
    let sellerId: String
    let name: String
    let description: String
    let basePrice: Double
    let status: Int
    let categoryId: Int
    let quantity: Int
    let createdAt: String
    let updatedAt: String
    let productImages: [SBProductImage]
    let productVariants: [SBProductVariant]
    let listTag: [String]
}

struct SBProductResponse: Codable {
    let result: Int
    let data: [SBProduct]?
    let error: APIErrorResponse?
}

struct RecommendationResponse: Codable {
    let recommendedProducts: [SBProduct]
}

struct CreateProductVariant: Codable {
    let productId: Int = 0
    let size: String
    let color: String
    let price: Double
    let status: Int = 0
}

struct CreateProductRequest: Codable {
    let id: Int = 0
    let sellerId: String
    let name: String
    let description: String
    let basePrice: Double
    let status: Int = 0
    let categoryId: Int
    let quantity: Int
    let productImages: [String]
    let productVariants: [CreateProductVariant]
    let tags: [String]
}

struct CreateProductResponse: Codable {
    let result: Int
    let data: SBProduct?
    let error: APIErrorResponse?
}
