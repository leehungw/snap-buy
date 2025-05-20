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
}
