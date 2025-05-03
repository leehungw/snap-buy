import SwiftUI
import GoogleSignIn

@main
struct RootView: App {
    
    var body: some Scene {
        WindowGroup {
            if SBUserDefaultService.instance.didShowOnboarding {
                SBLoginView()
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
                    .onAppear {
                        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                            // Check if `user` exists; otherwise, do something with `error`
                        }
                    }
            } else {
                SBOBView()
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
            }
        }
    }
}
