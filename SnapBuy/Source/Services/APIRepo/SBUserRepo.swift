import Foundation

struct UserLoginRequest: Codable {
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
    
    func login(request: UserLoginRequest, completion: @escaping (Result<UserLoginResponse, Error>) -> Void) {
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
}
