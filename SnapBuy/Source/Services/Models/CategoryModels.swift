import Foundation

struct SBCategory: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let title: String
    let imageUrl: String
    let parentId: Int
    let numberOfProduct: Int
    let createdAt: String
}

struct CategoryResponse: Codable {
    let result: Int
    let data: [SBCategory]?
    let error: APIErrorResponse?
}
