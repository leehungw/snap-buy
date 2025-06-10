import Foundation

// Add EmptyResponse type
struct EmptyResponse: Codable {
    let result: Int
    let error: APIErrorResponse?
}

final class VoucherRepository {
    static let shared = VoucherRepository()
    private init() {}
    
    // MARK: - Fetch All Vouchers
    func fetchAllVouchers(completion: @escaping (Result<[VoucherModel], Error>) -> Void) {
        print("🎫 Fetching all vouchers")
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/vouchers",
            method: "GET",
            body: nil,
            headers: headers
        ) { (result: Result<VoucherListResponse, Error>) in
            switch result {
            case .success(let response):
                if let vouchers = response.data {
                    print("✅ Successfully fetched \(vouchers.count) vouchers")
                    completion(.success(vouchers))
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "VoucherRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to fetch vouchers"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ No vouchers found")
                    let error = NSError(
                        domain: "VoucherRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No vouchers found"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Create Voucher
    func createVoucher(
        type: VoucherType,
        value: Double,
        minOrderValue: Double,
        expiryDate: Date,
        isDisabled: Bool,
        completion: @escaping (Result<VoucherModel, Error>) -> Void
    ) {
        print("🎫 Creating new voucher")
        
        let voucher = [
            "id": 0,
            "code": "string",
            "type": type.rawValue,
            "value": value,
            "minOrderValue": minOrderValue,
            "expiryDate": ISO8601DateFormatter().string(from: expiryDate),
            "isDisabled": isDisabled,
            "createdAt": ISO8601DateFormatter().string(from: Date())
        ] as [String : Any]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: voucher) else {
            let error = NSError(
                domain: "VoucherRepository",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode voucher data"]
            )
            completion(.failure(error))
            return
        }
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/vouchers",
            method: "POST",
            body: jsonData,
            headers: headers
        ) { (result: Result<VoucherResponse, Error>) in
            switch result {
            case .success(let response):
                if let voucher = response.data {
                    print("✅ Successfully created voucher")
                    completion(.success(voucher))
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "VoucherRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to create voucher"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ Failed to create voucher")
                    let error = NSError(
                        domain: "VoucherRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to create voucher"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Update Voucher
    func updateVoucher(
        id: Int,
        type: VoucherType,
        value: Double,
        minOrderValue: Double,
        expiryDate: Date,
        isDisabled: Bool,
        completion: @escaping (Result<VoucherModel, Error>) -> Void
    ) {
        print("🎫 Updating voucher \(id)")
        
        // First fetch the current voucher to get its code and createdAt
        SBAPIService.shared.performRequest(
            endpoint: "order/api/vouchers/\(id)",
            method: "GET",
            body: nil,
            headers: ["Content-Type": "application/json"]
        ) { [weak self] (result: Result<VoucherResponse, Error>) in
            switch result {
            case .success(let response):
                if let currentVoucher = response.data {
                    // Create ISO8601 formatter with milliseconds
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    let voucher = [
                        "id": currentVoucher.id,
                        "code": currentVoucher.code,  // Keep existing code
                        "type": currentVoucher.type,  // Keep existing type
                        "value": value,  // Can update
                        "minOrderValue": minOrderValue,  // Can update
                        "expiryDate": dateFormatter.string(from: expiryDate),  // Can update
                        "isDisabled": isDisabled,  // Can update
                        "createdAt": dateFormatter.string(from: currentVoucher.createdAt)  // Keep existing createdAt
                    ] as [String : Any]
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: voucher) else {
                        let error = NSError(
                            domain: "VoucherRepository",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to encode voucher data"]
                        )
                        completion(.failure(error))
                        return
                    }
                    
                    let headers = ["Content-Type": "application/json"]
                    
                    print("🌐 Request Body: \(String(data: jsonData, encoding: .utf8) ?? "")")
                    
                    SBAPIService.shared.performRequest(
                        endpoint: "order/api/vouchers",  // Base endpoint without ID
                        method: "PUT",
                        body: jsonData,
                        headers: headers
                    ) { (result: Result<VoucherResponse, Error>) in
                        switch result {
                        case .success(let response):
                            if let voucher = response.data {
                                print("✅ Successfully updated voucher")
                                completion(.success(voucher))
                            } else if let error = response.error {
                                print("❌ API Error: \(error)")
                                let apiError = NSError(
                                    domain: "VoucherRepository",
                                    code: error.code,
                                    userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to update voucher"]
                                )
                                completion(.failure(apiError))
                            } else {
                                print("❌ Failed to update voucher")
                                let error = NSError(
                                    domain: "VoucherRepository",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Failed to update voucher"]
                                )
                                completion(.failure(error))
                            }
                        case .failure(let error):
                            print("❌ Network Error: \(error.localizedDescription)")
                            completion(.failure(error))
                        }
                    }
                } else {
                    let error = NSError(
                        domain: "VoucherRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to fetch current voucher data"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get Available Vouchers
    func getAvailableVouchers(userId: String, orderTotal: Double, completion: @escaping (Result<[VoucherModel], Error>) -> Void) {
        print("🎫 Fetching available vouchers for order total: $\(orderTotal)")
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/vouchers/\(userId)/\(orderTotal)",
            method: "GET",
            body: nil,
            headers: headers
        ) { (result: Result<VoucherListResponse, Error>) in
            switch result {
            case .success(let response):
                if let vouchers = response.data {
                    print("✅ Successfully fetched \(vouchers.count) available vouchers")
                    completion(.success(vouchers))
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "VoucherRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to fetch available vouchers"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ No available vouchers found")
                    let error = NSError(
                        domain: "VoucherRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No available vouchers found"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Record Voucher Usage
    func recordVoucherUsage(code: String, userId: String, orderId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("🎫 Recording voucher usage for code: \(code)")
        
        let usage = [
            "code": code,
            "userId": userId,
            "orderId": orderId
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: usage) else {
            let error = NSError(
                domain: "VoucherRepository",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode voucher usage data"]
            )
            completion(.failure(error))
            return
        }
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/voucherUsages",
            method: "POST",
            body: jsonData,
            headers: headers
        ) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success(let response):
                if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "VoucherRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to record voucher usage"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("✅ Successfully recorded voucher usage")
                    completion(.success(()))
                }
            case .failure(let error):
                print("❌ Failed to record voucher usage: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Delete Voucher
    func deleteVoucher(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        print("🎫 Deleting voucher \(id)")
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/vouchers/\(id)",
            method: "DELETE",
            body: nil,
            headers: headers
        ) { (result: Result<DeleteVoucherResponse, Error>) in
            switch result {
            case .success(let response):
                if response.result > 0 {
                    print("✅ Successfully deleted voucher")
                    completion(.success(()))
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "VoucherRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to delete voucher"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ Failed to delete voucher")
                    let error = NSError(
                        domain: "VoucherRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to delete voucher"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
} 
