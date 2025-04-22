import SwiftUI

@main
struct RootView: App {
    
    var body: some Scene {
        WindowGroup {
            if SBUserDefaultService.instance.didShowOnboarding {
               // SBVerificationView()
                SBHomeTabbarView()
            } else {
               // SBOBView()
                SBHomeTabbarView()
            }
        }
    }
}
