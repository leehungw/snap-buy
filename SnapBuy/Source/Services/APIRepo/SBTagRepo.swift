

import Foundation

// MARK: - Tag Repository

final class TagRepository {
    static let shared = TagRepository()
    private init() {}

    private(set) var tags: [SBTag] = []

    /// Fetch all tags from the server
    func fetchTags(completion: @escaping (Result<[SBTag], Error>) -> Void) {
        let endpoint = "product/api/tags"
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<TagResponse, Error>) in
            switch result {
            case .success(let response):
                if let list = response.data {
                    self.tags = list
                    completion(.success(list))
                } else {
                    let message = response.error?.message ?? "No tags returned"
                    let err = NSError(
                        domain: "TagRepository",
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
