
import SwiftUI

struct SBHomeTabbarView: View {
    @State private var tabSelection = 1
    @Namespace private var namespace

        var body: some View {
                TabView(selection: $tabSelection) {
                    SBHomeView()
                        .tag(1)
                    
                    FavouriteView()
                        .tag(2)
                    
                    SBCartView()
                        .tag(3)
                    
                    SBCombinedSearchView()
                        .tag(4)
                    
                    UserView()
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
