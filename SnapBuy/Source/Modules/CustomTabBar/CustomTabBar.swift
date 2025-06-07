import SwiftUI
import Combine

enum BuyerTab: String, CaseIterable {
    case home = "Home"
    case notification = "Notification"
    case cart = "Cart"
    case search = "Search"
    case user = "User"
    
    var systemImage: String {
        switch self {
        case .home: return "house"
        case .notification: return "bell"
        case .cart: return "cart"
        case .search: return "magnifyingglass"
        case .user: return "person"
        }
    }
}

enum SellerTab: String, CaseIterable {
    case dashboard = "Dashboard"
    case products = "Products"
    case orders = "Orders"
    case statistics = "Statistics"
    
    var systemImage: String {
        switch self {
        case .dashboard: return "chart.bar"
        case .products: return "shippingbox"
        case .orders: return "list.clipboard"
        case .statistics: return "chart.pie"
        }
    }
}

struct CustomTabBar: View {
    @Binding var tabSelection: Int
    var animation: Namespace.ID
    @Binding var showNotificationDot: Bool
    @StateObject private var userModeManager = UserModeManager.shared
    
    private var tabWidth: CGFloat {
        return screenWidth/(userModeManager.currentMode == .buyer ? 5 : 4)
    }
    
    @State private var midPoint: CGFloat = 0.0
    
    var body: some View {
        let midSize: CGFloat = screenWidth * (200/1000)
        
        ZStack() {
            BezierCurvePath(midPoint: midPoint)
                .foregroundStyle(.white)
                .shadow(radius: 5)
            
            HStack(spacing: 0.0) {
                if userModeManager.currentMode == .buyer {
                    ForEach(0..<BuyerTab.allCases.count, id: \.self) { index in
                        let tab = BuyerTab.allCases[index]
                        tabButton(title: tab.rawValue,
                                systemImage: tab.systemImage,
                                index: index,
                                midSize: midSize,
                                totalTabs: 5)
                    }
                } else {
                    ForEach(0..<SellerTab.allCases.count, id: \.self) { index in
                        let tab = SellerTab.allCases[index]
                        tabButton(title: tab.rawValue,
                                systemImage: tab.systemImage,
                                index: index,
                                midSize: midSize,
                                totalTabs: 4)
                    }
                }
            }
        }
        .frame(maxHeight: midSize)
        .onAppear {
            updateMidPoint()
        }
        .onChange(of: tabSelection) { _ in
            updateMidPoint()
        }
        .onChange(of: userModeManager.currentMode) { _ in
            updateMidPoint()
        }
    }
    
    private func tabButton(title: String, systemImage: String, index: Int, midSize: CGFloat, totalTabs: Int) -> some View {
        let isCurrentTab = tabSelection == index + 1
        let isNotificationTab = userModeManager.currentMode == .buyer && title == BuyerTab.notification.rawValue
        
        return Button {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                tabSelection = index + 1
                updateMidPoint()
            }
        } label: {
            VStack(spacing: 2.0) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: systemImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .aspectRatio(isCurrentTab ? 0.4 : 0.6, contentMode: .fit)
                        .frame(
                            width: isCurrentTab ? midSize : 35.0,
                            height: isCurrentTab ? midSize : 35.0)
                        .foregroundStyle(
                            isCurrentTab ? .white : .gray
                        )
                        .background {
                            if isCurrentTab {
                                Circle()
                                    .fill(.main.gradient)
                                    .matchedGeometryEffect(id: "CurveAnimation", in: animation)
                            }
                        }
                        .offset(y: isCurrentTab ? -(midSize/2) : 0.0)
                    if isNotificationTab && showNotificationDot {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 8, y: -8)
                    }
                }
                if !isCurrentTab {
                    Text(title)
                        .font(.caption)
                        .fontDesign(.rounded)
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(isCurrentTab ? .white : .gray)
            .offset(y: !isCurrentTab ? -8.0 : 0.0)
        }
        .buttonStyle(.plain)
    }
    
    private func updateMidPoint() {
        // Determine number of tabs for current mode
        let totalTabs = userModeManager.currentMode == .buyer
            ? BuyerTab.allCases.count
            : SellerTab.allCases.count

        // Calculate zero-based index for selection
        let index = CGFloat(tabSelection - 1)

        // Center position: (totalTabs - 1) / 2 allows even/odd handling
        let centerPosition = CGFloat(totalTabs - 1) / 2

        // Compute midPoint offset
        midPoint = (centerPosition - index) * tabWidth
    }
}

#Preview {
    SBHomeTabbarView()
}
