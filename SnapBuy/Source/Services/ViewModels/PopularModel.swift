import SwiftUI

struct PopularItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
    let badge: String
    let badgeColor: Color

    static let sampleList: [PopularItem] = [
        PopularItem(imageName: "jacket", title: "Lunilo Hils jacket", subtitle: "1,6k Search today", badge: "Hot", badgeColor: .red),
        PopularItem(imageName: "jeans", title: "Denim Jeans", subtitle: "1k Search today", badge: "New", badgeColor: .orange),
        PopularItem(imageName: "backpack", title: "Redil Backpack", subtitle: "1,23k Search today", badge: "Popular", badgeColor: .green),
        PopularItem(imageName: "speaker", title: "JBL Speakers", subtitle: "1,1k Search today", badge: "New", badgeColor: .orange)
    ]
}
