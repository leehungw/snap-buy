import Foundation

struct ReviewRequest: Codable {
    let id: Int
    let orderId: String
    let productId: Int
    let starNumber: Int
    let reviewComment: String
    let productReviewImages: [String]
    let productNote: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case orderId
        case productId
        case starNumber
        case reviewComment
        case productReviewImages
        case productNote
        case userId
    }
}

struct ReviewResponse: Codable {
    let result: Int
    let data: ReviewData?
    let error: ReviewError?
}

struct ReviewError: Codable {
    let code: Int
    let message: String
}

struct ReviewUserData: Codable {
    let id: String
    let name: String
    let imageURL: String
    let userName: String
    let email: String
    let lastProductId: Int
}

struct ReviewData: Codable {
    let id: Int
    let productId: Int
    let starNumber: Int
    let orderId: String
    let productNote: String
    let userId: String
    let reviewComment: String
    let productReviewImages: [String]
    var user: ReviewUserData?
}

struct ValidationError: Codable {
    let type: String
    let title: String
    let status: Int
    let errors: [String: [String]]
    let traceId: String
}

// Product Review Models
struct ProductReviewResponse: Codable {
    let result: Int
    let data: [ProductReview]
    let error: APIErrorResponse?
}

struct ProductReview: Codable, Identifiable {
    let id: Int
    let productId: Int
    let starNumber: Double
    let orderId: String
    let productNote: String
    let userId: String
    let reviewComment: String
    var productReviewImages: [String]
    var user: ReviewUserData?
    
    var reviewerName: String {
        user?.name ?? "Anonymous"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, productId, starNumber, orderId, productNote, userId, reviewComment, productReviewImages, user
    }
    
    init(id: Int, productId: Int, starNumber: Double, orderId: String, productNote: String, userId: String, reviewComment: String, productReviewImages: [String], user: ReviewUserData?) {
        self.id = id
        self.productId = productId
        self.starNumber = starNumber
        self.orderId = orderId
        self.productNote = productNote
        self.userId = userId
        self.reviewComment = reviewComment
        self.productReviewImages = productReviewImages
        self.user = user
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        productId = try container.decode(Int.self, forKey: .productId)
        starNumber = try container.decode(Double.self, forKey: .starNumber)
        orderId = try container.decode(String.self, forKey: .orderId)
        productNote = try container.decode(String.self, forKey: .productNote)
        userId = try container.decode(String.self, forKey: .userId)
        reviewComment = try container.decode(String.self, forKey: .reviewComment)
        user = try? container.decodeIfPresent(ReviewUserData.self, forKey: .user)
        
        // Handle potentially invalid image array
        if let rawImages = try? container.decode([String].self, forKey: .productReviewImages) {
            productReviewImages = rawImages.filter { !$0.contains("ProductService.Models.Entities") }
        } else {
            productReviewImages = []
        }
    }
} 
