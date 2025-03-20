import SwiftUI

struct SBBaseView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        NavigationView {
            VStack {
                content()
            }
            .navigationBarBackButtonHidden(true)
            
        }
    }
}
