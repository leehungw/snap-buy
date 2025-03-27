import SwiftUI

struct SBOBPageView: View {
    struct Page {
        let image: Image
        let title: String
        let subtitle: String
    }
    var page: Page

    var body: some View {
        VStack {
            page.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.bottom, 20)

            Text(page.title)
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)

            Text(page.subtitle)
                .foregroundColor(.gray)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding()
    }
}
