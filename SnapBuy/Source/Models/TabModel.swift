
import SwiftUI

enum TabModel: String, CaseIterable {
    
    case home = "Home"
    case noti = "Notification"
    case cart = "Cart"
    case search = "Search"
    case user = "User"
    
    var systemImage: String {
        switch self {
        case .home:
            return "house"
        case .noti:
            return "bell"
        case .cart:
            return "cart"
        case .search:
            return "magnifyingglass"
        case .user:
            return "person"
        }
    }
    
    var index: Int {
        return TabModel.allCases.firstIndex(of: self) ?? 0
    }
}
