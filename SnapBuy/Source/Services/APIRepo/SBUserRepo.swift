import Foundation

final class UserRepository {
    static let shared = UserRepository()
    private init() {}
    
    var currentUser: UserData?

    
    func login(request: UserLoginRequest, completion: @escaping SBValueAction<Result<UserLoginResponse, Error>>) {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            let encodingError = NSError(domain: "UserRepository", code: -1002, userInfo: [NSLocalizedDescriptionKey: "Unable to encode login request"])
            completion(.failure(encodingError))
            return
        }
        
        SBAPIService.shared.performRequest(endpoint: "user/api/users/login",
                                           method: "POST",
                                           body: jsonData,
                                           headers: nil) { (result: Result<UserLoginResponse, Error>) in
            switch result {
            case .success(var response):
                if var userData = response.data {
                    // Convert empty merchant ID to nil
                    if let merchantId = userData.sellerMerchantId, merchantId.isEmpty {
                        userData = self.userDataWithNilMerchantId(userData)
                    }
                    UserRepository.shared.currentUser = userData
                }
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loginWithGoogle(request: GoogleLoginRequest, completion: @escaping SBValueAction<Result<UserLoginResponse, Error>>) {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            let encodingError = NSError(domain: "UserRepository", code: -1003, userInfo: [NSLocalizedDescriptionKey: "Unable to encode Google login request"])
            completion(.failure(encodingError))
            return
        }
        
        SBAPIService.shared.performRequest(endpoint: "user/api/users/loginWithGoogle",
                                           method: "POST",
                                           body: jsonData,
                                           headers: nil) { (result: Result<UserLoginResponse, Error>) in
            switch result {
            case .success(var response):
                if var userData = response.data {
                    // Convert empty merchant ID to nil
                    if let merchantId = userData.sellerMerchantId, merchantId.isEmpty {
                        userData = self.userDataWithNilMerchantId(userData)
                    }
                    UserRepository.shared.currentUser = userData
                }
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Helper function to create a new UserData instance with nil merchantId
    private func userDataWithNilMerchantId(_ userData: UserData) -> UserData {
        return UserData(
            id: userData.id,
            name: userData.name,
            imageURL: userData.imageURL,
            userName: userData.userName,
            email: userData.email,
            isAdmin: userData.isAdmin,
            isPremium: userData.isPremium,
            isBanned: userData.isBanned,
            sellerMerchantId: nil,
            lastProductId: userData.lastProductId
        )
    }
    
    func signUp(request: SignUpRequest, completion: @escaping SBValueAction<Result<UserLoginResponse, Error>>) {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            let encodingError = NSError(domain: "UserRepository", code: -1004, userInfo: [NSLocalizedDescriptionKey: "Unable to encode sign up request"])
            completion(.failure(encodingError))
            return
        }
        
        SBAPIService.shared.performRequest(endpoint: "api/users/signUp",
                                           method: "POST",
                                           body: jsonData,
                                           headers: nil) { (result: Result<UserLoginResponse, Error>) in
            switch result {
            case .success(let response):
                if let userData = response.data {
                    UserRepository.shared.currentUser = userData
                }
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateProfile(request: UpdateProfileRequest, completion: @escaping SBValueAction<Result<UserLoginResponse, Error>>) {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            let encodingError = NSError(domain: "UserRepository", code: -1006, userInfo: [NSLocalizedDescriptionKey: "Unable to encode update profile request"])
            completion(.failure(encodingError))
            return
        }
        
        SBAPIService.shared.performRequest(endpoint: "api/users/profile",
                                           method: "PUT",
                                           body: jsonData,
                                           headers: nil) { (result: Result<UserLoginResponse, Error>) in
            switch result {
            case .success(let response):
                if let userData = response.data {
                    UserRepository.shared.currentUser = userData
                }
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updatePassword(request: UpdatePasswordRequest, completion: @escaping SBValueAction<Result<UserLoginResponse, Error>>) {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            let encodingError = NSError(domain: "UserRepository", code: -1007, userInfo: [NSLocalizedDescriptionKey: "Unable to encode update password request"])
            completion(.failure(encodingError))
            return
        }
        
        SBAPIService.shared.performRequest(endpoint: "api/users/password",
                                           method: "PUT",
                                           body: jsonData,
                                           headers: nil) { (result: Result<UserLoginResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout() {
        self.currentUser = nil
    }
    
    // MARK: - Admin Functions
    
    func fetchAllUsers(completion: @escaping SBValueAction<Result<AdminUsersResponse, Error>>) {
        SBAPIService.shared.performRequest(endpoint: "user/api/users",
                                           method: "GET",
                                           body: nil,
                                           headers: nil,
                                           completion: completion)
    }
    
    func fetchUserDetail(userId: String, completion: @escaping SBValueAction<Result<AdminUserDetailResponse, Error>>) {
        SBAPIService.shared.performRequest(endpoint: "user/api/users/\(userId)",
                                           method: "GET",
                                           body: nil,
                                           headers: nil,
                                           completion: completion)
    }
    
    func banUser(userId: String, completion: @escaping SBValueAction<Result<BanUnbanResponse, Error>>) {
        SBAPIService.shared.performRequest(endpoint: "user/api/users/banUser/\(userId)",
                                           method: "PUT",
                                           body: nil,
                                           headers: nil,
                                           completion: completion)
    }
    
    func unbanUser(userId: String, completion: @escaping SBValueAction<Result<BanUnbanResponse, Error>>) {
        SBAPIService.shared.performRequest(endpoint: "user/api/users/unbanUser/\(userId)",
                                           method: "PUT",
                                           body: nil,
                                           headers: nil,
                                           completion: completion)
    }
    
    func fetchSellerStats(userId: String, completion: @escaping SBValueAction<Result<SellerStatsResponse, Error>>) {
        SBAPIService.shared.performRequest(endpoint: "user/api/users/\(userId)/seller-stats",
                                           method: "GET",
                                           body: nil,
                                           headers: nil,
                                           completion: completion)
    }
    
    /// Fetch user information by user ID
    func fetchUserById(userId: String, completion: @escaping SBValueAction<Result<UserData, Error>>) {
        let endpoint = "user/api/users/\(userId)"
        
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<UserLoginResponse, Error>) in
            switch result {
            case .success(let response):
                if let userData = response.data {
                    completion(.success(userData))
                } else {
                    let err = NSError(
                        domain: "UserRepository",
                        code: response.error?.code ?? -1,
                        userInfo: [NSLocalizedDescriptionKey: response.error?.message ?? "Failed to fetch user data"]
                    )
                    completion(.failure(err))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Update the user's lastProductId on the server when they view a product
    func updateLastProduct(productId: Int, completion: @escaping SBValueAction<Result<Void, Error>>) {
        // Ensure we have a user ID
        guard let userId = UserRepository.shared.currentUser?.id else {
            let err = NSError(
                domain: "UserRepository",
                code: -1005,
                userInfo: [NSLocalizedDescriptionKey: "User not signed in"]
            )
            completion(.failure(err))
            return
        }

        // Construct endpoint
        let endpoint = "user/api/users/lastProduct/\(userId)/\(productId)"

        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "PUT",
            body: nil,
            headers: nil
        ) { (result: Result<APIErrorResponse, Error>) in
            switch result {
            case .success(let response):
                if response.code == 200 {
                    // Optionally update local user
                    completion(.success(()))
                } else {
                    let err = NSError(
                        domain: "UserRepository",
                        code: response.code,
                        userInfo: [NSLocalizedDescriptionKey: response.message]
                    )
                    completion(.failure(err))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Stats Functions
    
    func fetchBuyerStats(userId: String, completion: @escaping SBValueAction<Result<BuyerStats, Error>>) {
        let endpoint = "order/api/orders/buyer/stats/\(userId)"
        
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<BuyerStatsResponse, Error>) in
            switch result {
            case .success(let response):
                if let stats = response.data {
                    completion(.success(stats))
                } else {
                    let err = NSError(
                        domain: "UserRepository",
                        code: response.error?.code ?? -1,
                        userInfo: [NSLocalizedDescriptionKey: response.error?.message ?? "Failed to fetch buyer stats"]
                    )
                    completion(.failure(err))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchSellerStats(userId: String, completion: @escaping SBValueAction<Result<SellerStats, Error>>) {
        let endpoint = "order/api/orders/seller/stats/\(userId)"
        
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<SellerStatsResponse, Error>) in
            switch result {
            case .success(let response):
                if let stats = response.data {
                    completion(.success(stats))
                } else {
                    let err = NSError(
                        domain: "UserRepository",
                        code: response.error?.code ?? -1,
                        userInfo: [NSLocalizedDescriptionKey: response.error?.message ?? "Failed to fetch seller stats"]
                    )
                    completion(.failure(err))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateMerchantId(userId: String, merchantId: String, completion: @escaping SBValueAction<Result<UserLoginResponse, Error>>) {
        // Create request body
        let request = [
            "id": userId,
            "selleR_MERCHANT_ID": merchantId
        ]
        
        guard let jsonData = try? JSONEncoder().encode(request) else {
            let encodingError = NSError(
                domain: "UserRepository",
                code: -1008,
                userInfo: [NSLocalizedDescriptionKey: "Unable to encode merchant ID update request"]
            )
            completion(.failure(encodingError))
            return
        }
        
        SBAPIService.shared.performRequest(
            endpoint: "user/api/users/updateMerchantId",
            method: "PUT",
            body: jsonData,
            headers: nil
        ) { (result: Result<UserLoginResponse, Error>) in
            switch result {
            case .success(let response):
                if let userData = response.data {
                    // Update the current user data with the new merchant ID
                    UserRepository.shared.currentUser = userData
                }
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
