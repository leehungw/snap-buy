
import SwiftUI

struct ContentView: View {
    @State private var tabSelection = 1
    @Namespace private var namespace

        var body: some View {
                TabView(selection: $tabSelection) {
                    HomeView()
                        .tag(1)
                    
                    FavouriteView()
                        .tag(2)
                    
                    CartView()
                        .tag(3)
                    
                    NotiView()
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
    ContentView()
}
