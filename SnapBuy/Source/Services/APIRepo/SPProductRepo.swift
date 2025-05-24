import Foundation

final class ProductRepository {
    static let shared = ProductRepository()
    private init() {}

    private(set) var products: [SBProduct] = []

    func fetchProducts(categoryId: Int,
                       completion: @escaping (Result<[SBProduct], Error>) -> Void) {
        let endpoint = "product/api/products/category/\(categoryId)"
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<SBProductResponse, Error>) in
            switch result {
            case .success(let response):
                if let list = response.data {
                    self.products = list
                    completion(.success(list))
                } else {
                    let message = response.error?.message ?? "No products returned"
                    let err = NSError(
                        domain: "ProductRepository",
                        code: response.error?.code ?? -1,
                        userInfo: [NSLocalizedDescriptionKey: message]
                    )
                    completion(.failure(err))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    /// Fetch recommended products for the currently signed-in user
    func fetchRecommendedProducts(completion: @escaping (Result<[SBProduct], Error>) -> Void) {
        // Ensure we have a user ID
//        guard let userId = UserRepository.shared.currentUser?.id else {
//            let err = NSError(
//                domain: "ProductRepository",
//                code: -1,
//                userInfo: [NSLocalizedDescriptionKey: "User not signed in"]
//            )
//            completion(.failure(err))
//            return
//        }
        
        let userId = "5624994f-3a1a-4fa0-83ec-529ec3530f91"

        let body: [String: String] = ["userId": userId]
        guard let data = try? JSONEncoder().encode(body) else { return }

        SBAPIService.shared.performRequest(
            endpoint: ":5001/recommend",
            method: "POST",
            body: data,
            headers: nil
        ) { (result: Result<RecommendationResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.recommendedProducts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
