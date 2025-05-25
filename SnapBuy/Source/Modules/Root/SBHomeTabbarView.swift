import SwiftUI
import Combine

struct SBHomeTabbarView: View {
    @State private var tabSelection = 1
    @Namespace private var namespace
    @State private var notificationCancellable: AnyCancellable?
    
    var body: some View {
        TabView(selection: $tabSelection) {
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
        }
        .onAppear {
            notificationCancellable = NotificationCenter.default.publisher(for: .selectTab)
                .compactMap { $0.userInfo?["tab"] as? Int }
                .sink { newTab in
                    // Animate selection change immediately
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                        tabSelection = newTab
                    }
                }
        }
        .overlay(alignment: .bottom) {
            CustomTabBar(
                tabSelection: $tabSelection,
                animation: namespace
            )
        }
        .ignoresSafeArea()
    }
    
}



#Preview {
    SBHomeTabbarView()
}
