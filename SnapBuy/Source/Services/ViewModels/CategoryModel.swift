import Foundation

struct Category: Identifiable {
    let id = UUID()
    let title: String
    let productCount: Int
    let imageName: String
}
