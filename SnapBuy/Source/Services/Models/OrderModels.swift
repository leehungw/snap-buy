import Foundation

enum OrderStatus: String, Identifiable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case success = "Success"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
    
    var id: String { self.rawValue }
    
    static var allCases: [OrderStatus] {
        return [.pending, .inProgress, .delivered, .success, .cancelled]
    }
    
    static func fromString(_ value: String) -> OrderStatus? {
        return OrderStatus.allCases.first {
            $0.rawValue.capitalized == value.lowercased()
        }
    }
    
    static var allValues: [String] {
        return allCases.map { $0.rawValue }
    }
}

struct SBOrderModel: Codable, Identifiable {
    var id: String
    var buyerId: String
    var sellerId: String
    var totalAmount: Double
    var shippingAddress: String
    var orderItems: [SBOrderItemModel]
    var status: String
}

struct SBOrderItemModel: Codable, Identifiable {
    var id: Int
    var orderId: String
    var productId: Int
    var productName: String
    var productImageUrl: String
    var productNote: String
    var productVariantId: Int
    var quantity: Int
    var unitPrice: Double
    var isReviewed: Bool
}

// MARK: - Response Models
struct OrderResponse: Codable {
    let data: SBOrderModel?
    let error: APIErrorResponse?
}

struct OrderListResponse: Codable {
    let data: [SBOrderModel]?
    let error: APIErrorResponse?
}

struct OrderItemsResponse: Codable {
    let data: [SBOrderItemModel]?
    let error: APIErrorResponse?
}

