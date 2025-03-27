import SwiftUI

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let brand: String
    let price: Double
    let imageName: String
}
