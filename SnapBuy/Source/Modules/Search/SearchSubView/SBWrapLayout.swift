import SwiftUI

struct WrapLayout<T: Hashable, Content: View>: View {
    let data: [T]
    let spacing: CGFloat
    let content: (T) -> Content

    init(data: [T], spacing: CGFloat = 8, @ViewBuilder content: @escaping (T) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(data, id: \.self) { item in
                    content(item)
                }
            }
            .padding(.horizontal)
        }
    }
}
