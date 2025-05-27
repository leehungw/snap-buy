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
        
        SBAPIService.shared.performRequest(endpoint: "api/users/login",
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
    
    func loginWithGoogle(request: GoogleLoginRequest, completion: @escaping SBValueAction<Result<UserLoginResponse, Error>>) {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            let encodingError = NSError(domain: "UserRepository", code: -1003, userInfo: [NSLocalizedDescriptionKey: "Unable to encode Google login request"])
            completion(.failure(encodingError))
            return
        }
        
        SBAPIService.shared.performRequest(endpoint: "api/users/loginWithGoogle",
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
}
