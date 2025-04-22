import SwiftUI

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let color: Color
    var isSelected: Bool = false
}

let locations: [Location] = [
    Location(name: "Los Angeles", subtitle: "Los Angeles, United States", color: .green),
    Location(name: "San Francisco", subtitle: "San Francisco, United States", color: .purple),
    Location(name: "New York", subtitle: "New York, United States", color: .pink)
]

