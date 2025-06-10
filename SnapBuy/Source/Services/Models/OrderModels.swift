import Foundation
import SwiftUI

enum OrderStatus: String, Identifiable {
    case pending = "Pending"
    case approve = "Approved"
    case success = "Success"
    case failed = "Failed"
    
    var id: String { self.rawValue }
    
    static var allCases: [OrderStatus] {
        return [.pending, .approve, .success, .failed]
    }
    
    static func fromString(_ value: String) -> OrderStatus? {
        return OrderStatus.allCases.first {
            $0.rawValue.lowercased() == value.lowercased()
        }
    }
    
    static var allValues: [String] {
        return allCases.map { $0.rawValue }
    }
    
    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .approve:
            return .blue
        case .success:
            return .green
        case .failed:
            return .red
        }
    }
}

struct SBOrderModel: Codable, Identifiable {
    var id: String
    var buyerId: String
    var sellerId: String
    var totalAmount: Double
    var shippingAddress: String
    var phoneNumber: String
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
