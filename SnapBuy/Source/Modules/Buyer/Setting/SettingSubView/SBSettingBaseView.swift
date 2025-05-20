import SwiftUI

struct SBSettingBaseView<Content: View>: View {
    let title: String
    let content: () -> Content
    @Environment(\.dismiss) var dismiss

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text(title)
                        .font(R.font.outfitRegular.font(size: 16))
                        .padding(.trailing, 10)
                    Spacer()
                }
                .padding()
                Divider()
                content()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}
