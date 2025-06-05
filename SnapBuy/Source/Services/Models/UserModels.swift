import Foundation

struct UserLoginRequest: Codable {
    let email: String
    let password: String
}

struct GoogleLoginRequest: Codable {
    let googleId: String
    let email: String
}

struct SignUpRequest: Codable {
    let userName: String
    let email: String
    let password: String
}

struct UserData: Codable {
    let id: String
    let name: String
    let imageURL: String
    let userName: String
    let email: String
    let isAdmin: Bool
    let isPremium: Bool
    let isBanned: Bool
    let sellerMerchantId: String?
    let lastProductId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageURL
        case userName
        case email
        case isAdmin
        case isPremium
        case isBanned
        case sellerMerchantId = "selleR_MERCHANT_ID"
        case lastProductId
    }
}

struct APIErrorResponse: Codable {
    let code: Int
    let message: String
}

struct UserLoginResponse: Codable {
    let result: Int
    let data: UserData?
    let error: APIErrorResponse?
}

// Generic response for user data
struct UserResponse: Codable {
    let result: Int
    let data: UserData?
    let error: APIErrorResponse?
}


struct UpdateProfileRequest: Codable {
    let userName: String
    let email: String
}

struct UpdatePasswordRequest: Codable {
    let newPassword: String
}



struct AdminUsersResponse: Codable {
    let result: Int
    let data: [UserData]
    let error: APIErrorResponse?
}

struct AdminUserDetailResponse: Codable {
    let result: Int
    let data: UserData?
    let error: APIErrorResponse?
}

struct BanUnbanResponse: Codable {
    let result: Int
    let data: Int
    let error: APIErrorResponse?
}

struct SellerStatsResponse: Codable {
    let result: Int
    let data: SellerStats?
    let error: APIErrorResponse?
}

struct SellerStats: Codable {
    let productCount: Int
    let totalRevenue: Double
    let totalPurchases: Int
}

struct BuyerStatsResponse: Codable {
    let result: Int
    let data: BuyerStats?
    let error: APIErrorResponse?
}

struct BuyerStats: Codable {
    let purchaseCount: Int
    let totalSpent: Double
    let totalOrders: Int
}
