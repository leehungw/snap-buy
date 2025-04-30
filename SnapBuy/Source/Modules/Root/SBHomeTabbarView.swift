
import SwiftUI

struct SBHomeTabbarView: View {
    @State private var tabSelection = 1
    @Namespace private var namespace

        var body: some View {
                TabView(selection: $tabSelection) {
                    SBHomeView()
                        .tag(1)
                    
                    SBCombinedSearchView()
                        .tag(2)
                    
                    SBCartView()
                        .tag(3)
                    
                    SBCombinedSearchView()
                        .tag(4)
                    
                    SBUserView()
                        .tag(5)
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
