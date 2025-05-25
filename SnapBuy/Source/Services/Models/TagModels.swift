import Foundation
// MARK: - SBTag Model

struct SBTag: Codable, Identifiable {
    let id: Int
    let tagName: String
    let description: String
    let numberOfProduct: Int
    let createdAt: String
}

// MARK: - Tag API Response

struct TagResponse: Codable {
    let result: Int
    let data: [SBTag]?
    let error: APIErrorResponse?
}
