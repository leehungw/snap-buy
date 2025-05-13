import Foundation

struct SBCategory: Codable {
    let id: Int
    let name: String
    let parentId: Int
    let createdAt: String
}

struct CategoryResponse: Codable {
    let result: Int
    let data: [SBCategory]?
    let error: APIErrorResponse?
}

final class CategoryRepository {
    static let shared = CategoryRepository()
    private init() {}

    private(set) var categories: [SBCategory] = []

    func fetchCategories(completion: @escaping (Result<[SBCategory], Error>) -> Void) {
        SBAPIService.shared.performRequest(
            endpoint: "api/categories",
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<CategoryResponse, Error>) in
            switch result {
            case .success(let response):
                if let list = response.data {
                    self.categories = list
                    completion(.success(list))
                } else {
                    let message = response.error?.message ?? "No categories returned"
                    let err = NSError(
                        domain: "CategoryRepository",
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
