import Foundation

enum VoucherType: String, Codable, CaseIterable {
    case fixed = "fix"
    case percentage = "percentage"
}

struct VoucherModel: Codable, Identifiable {
    let id: Int
    let code: String
    let type: String
    let value: Double
    let minOrderValue: Double
    let expiryDate: Date
    let isDisabled: Bool
    let createdAt: Date
    let canUse: Bool?
    
    var formattedValue: String {
        if type == VoucherType.percentage.rawValue {
            return "\(Int(value))%"
        } else {
            return "$\(String(format: "%.2f", value))"
        }
    }
    
    var formattedMinOrderValue: String {
        return "$\(String(format: "%.2f", minOrderValue))"
    }
    
    var isExpired: Bool {
        return Date() > expiryDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id, code, type, value, minOrderValue, expiryDate, isDisabled, createdAt, canUse
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        type = try container.decode(String.self, forKey: .type)
        value = try container.decode(Double.self, forKey: .value)
        minOrderValue = try container.decode(Double.self, forKey: .minOrderValue)
        canUse = try container.decodeIfPresent(Bool.self, forKey: .canUse)
        
        // Handle date strings with multiple formatters
        let formatters = [
            ISO8601DateFormatter(),
            { () -> ISO8601DateFormatter in
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return formatter
            }(),
            { () -> DateFormatter in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                return formatter
            }()
        ]
        
        func parseDate(_ dateString: String) -> Date? {
            for formatter in formatters {
                if let date = (formatter as? ISO8601DateFormatter)?.date(from: dateString) {
                    return date
                }
                if let date = (formatter as? DateFormatter)?.date(from: dateString) {
                    return date
                }
            }
            return nil
        }
        
        let expiryDateString = try container.decode(String.self, forKey: .expiryDate)
        if let date = parseDate(expiryDateString) {
            expiryDate = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .expiryDate, in: container, debugDescription: "Invalid date format: \(expiryDateString)")
        }
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let date = parseDate(createdAtString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Invalid date format: \(createdAtString)")
        }
        
        // Handle optional isDisabled field
        isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(code, forKey: .code)
        try container.encode(type, forKey: .type)
        try container.encode(value, forKey: .value)
        try container.encode(minOrderValue, forKey: .minOrderValue)
        try container.encode(isDisabled, forKey: .isDisabled)
        if let canUse = canUse {
            try container.encode(canUse, forKey: .canUse)
        }
        
        // Format dates for encoding
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        try container.encode(formatter.string(from: expiryDate), forKey: .expiryDate)
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
    }
}

// MARK: - Response Models
struct VoucherResponse: Codable {
    let result: Int
    let data: VoucherModel?
    let error: APIErrorResponse?
}

struct VoucherListResponse: Codable {
    let result: Int
    let data: [VoucherModel]?
    let error: APIErrorResponse?
}

struct DeleteVoucherResponse: Codable {
    let result: Int
    let data: Int?  // Server returns number for delete operation
    let error: APIErrorResponse?
}
