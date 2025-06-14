import SwiftUI
import GoogleSignIn

@main
struct RootView: App {
    
    var body: some Scene {
        WindowGroup {
            if SBUserDefaultService.instance.didShowOnboarding {
                SBLoginView(shouldShowBackButton: false)
                    .onOpenURL { url in
                        if url.scheme == "snapbuy" {
                            UserModeManager.shared.handlePayPalReturn(url: url)
                        } else {
                            GIDSignIn.sharedInstance.handle(url)
                        }
                    }
                    .onAppear {
                        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                            // Check if `user` exists; otherwise, do something with `error`
                        }
                    }
            } else {
                SBOBView()
                    .onOpenURL { url in
                        if url.scheme == "snapbuy" {
                            UserModeManager.shared.handlePayPalReturn(url: url)
                        } else {
                            GIDSignIn.sharedInstance.handle(url)
                        }
                    }
            }
        }
    }
}
