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
    
    func updatePassword() {
        
    }
}
