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
    
    func fetchAcceptedProducts(completion: @escaping (Result<[SBProduct], Error>) -> Void) {
        let endpoint = "product/api/products/accept"
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<SBProductResponse, Error>) in
            switch result {
            case .success(let response):
                if let list = response.data {
                    completion(.success(list))
                } else {
                    let message = response.error?.message ?? "No accepted products returned"
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
    
    func fetchUnacceptedProducts(completion: @escaping (Result<[SBProduct], Error>) -> Void) {
        let endpoint = "product/api/products/unAccept"
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<SBProductResponse, Error>) in
            switch result {
            case .success(let response):
                if let list = response.data {
                    completion(.success(list))
                } else {
                    let message = response.error?.message ?? "No unaccepted products returned"
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
    func approveProduct(productId: Int, completion: @escaping (Result<ProductApprovalResponse, Error>) -> Void) {
        let endpoint = "product/api/products/approve/\(productId)"
        
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "PUT",
            body: nil,
            headers: nil,
            completion: completion
        )
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
    
    /// Fetch products according to filter criteria.
    ///
    /// - Parameters:
    ///   - name: product name substring or "null" to skip name filter
    ///   - startPrice: minimum price or 0 to skip price filter
    ///   - endPrice: maximum price or 0 to skip price filter
    ///   - categoryName: category name or "null" to skip category filter
    ///   - tag: tag or "null" to skip tag filter
    func fetchFilteredProducts(name: String,
                               startPrice: Double,
                               endPrice: Double,
                               categoryName: String,
                               tag: String,
                               completion: @escaping (Result<[SBProduct], Error>) -> Void) {
        // Prepare endpoint with parameters; this API expects literal "null" or 0 where filters are omitted
        let endpoint = "product/api/products/filter/\(name)/\(startPrice)/\(endPrice)/\(categoryName)/\(tag)"
        
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { [weak self] (result: Result<SBProductResponse, Error>) in guard let self else { return }
            switch result {
            case .success(let response):
                if let list = response.data {
                    products = list
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
    
    /// Fetch all products for a specific seller
    func fetchProductsBySellerId(sellerId: String, completion: @escaping (Result<[SBProduct], Error>) -> Void) {
        let endpoint = "product/api/products/seller/\(sellerId)"
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<SBProductResponse, Error>) in
            switch result {
            case .success(let response):
                if let products = response.data {
                    completion(.success(products))
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
    
    /// Create a new product
    func createProduct(request: CreateProductRequest, completion: @escaping (Result<SBProduct, Error>) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            let encodingError = NSError(domain: "ProductRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode product request"])
            completion(.failure(encodingError))
            return
        }
        
        SBAPIService.shared.performRequest(
            endpoint: "product/api/products/detail",
            method: "POST",
            body: jsonData,
            headers: nil
        ) { (result: Result<CreateProductResponse, Error>) in
            switch result {
            case .success(let response):
                if let product = response.data {
                    completion(.success(product))
                } else {
                    let message = response.error?.message ?? "Failed to create product"
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
    
    /// Fetch products by seller ID
    func fetchProductsBySellerId(_ sellerId: String, completion: @escaping (Result<[SBProduct], Error>) -> Void) {
        let endpoint = "product/api/products/seller/\(sellerId)"
        
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<SBProductResponse, Error>) in
            switch result {
            case .success(let response):
                if let products = response.data {
                    completion(.success(products))
                } else {
                    let message = response.error?.message ?? "No products found"
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
    
    func fetchSellerInfo(userId: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        let endpoint = "user/api/users/\(userId)"
        
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<UserResponse, Error>) in
            switch result {
            case .success(let response):
                if let user = response.data {
                    completion(.success(user))
                } else {
                    let message = response.error?.message ?? "Failed to fetch seller information"
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
}

