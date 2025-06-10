import SwiftUI
import Combine

struct SBHomeTabbarView: View {
    @State private var tabSelection = 1
    @Namespace private var namespace
    @State private var notificationCancellable: AnyCancellable?
    @State private var hideTabBarCancellable: AnyCancellable?
    @State private var showTabBarCancellable: AnyCancellable?
    @StateObject private var userModeManager = UserModeManager.shared
    @State private var showNotificationDot = false
    @State private var isTabBarVisible = true
    private let signalRService = SignalRService()
    
    var body: some View {
        ZStack {
            TabView(selection: $tabSelection) {
                if userModeManager.currentMode == .buyer {
                    SBHomeView()
                        .tag(1)
                    
                    SBNotificationView()
                        .tag(2)
                    
                    SBCartView()
                        .tag(3)
                    
                    SBCombinedSearchView()
                        .tag(4)
                    
                    SBUserView()
                        .tag(5)
                } else {
                    SBSellerDashboardView()
                        .tag(1)
                    
                    SBProductManagementView()
                        .tag(2)
                    
                    SBOrderManagementView()
                        .tag(3)
                    
                    SalesStatisticsView()
                        .tag(4)
                }
            }
            .overlay(alignment: .bottom) {
                if isTabBarVisible && ((userModeManager.currentMode == .buyer && tabSelection >= 1 && tabSelection <= 5) ||
                   (userModeManager.currentMode == .seller && tabSelection >= 1 && tabSelection <= 4)) {
                    CustomTabBar(
                        tabSelection: $tabSelection,
                        animation: namespace,
                        showNotificationDot: $showNotificationDot
                    )
                    .disabled(!isTabBarVisible)
                }
            }
            
            // Add blocking overlay when TabBar is hidden
            if !isTabBarVisible {
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 100)
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onAppear {
            setupNotifications()
            print("1231312311231313132")
            signalRService.startNotificationSignalR { userId in
                if let currentUserId = UserRepository.shared.currentUser?.id, userId == currentUserId {
                    showNotificationDot = true
                }
            }
        }
        .onChange(of: tabSelection) { newTab in
            // If notification tab is selected, clear the dot and fetch notifications
            if userModeManager.currentMode == .buyer && newTab == 2 {
                showNotificationDot = false
                if let userId = UserRepository.shared.currentUser?.id {
                    NotificationRepository.shared.fetchNotifications(for: userId) { _ in }
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: userModeManager.currentMode) { _ in
            tabSelection = 1
        }
    }
    
    private func setupNotifications() {
        notificationCancellable = NotificationCenter.default.publisher(for: .selectTab)
            .compactMap { $0.userInfo?["tab"] as? Int }
            .sink { newTab in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                    tabSelection = newTab
                }
            }
            
        hideTabBarCancellable = NotificationCenter.default.publisher(for: .hideTabBar)
            .sink { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isTabBarVisible = false
                }
            }
            
        showTabBarCancellable = NotificationCenter.default.publisher(for: .showTabBar)
            .sink { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isTabBarVisible = true
                }
            }
    }
}

#Preview {
    SBHomeTabbarView()
}
