import SwiftUI

struct AdminHeader: View {
    let title: String
    let dismiss: DismissAction

    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            Spacer()
            Text(title)
                .font(R.font.outfitBold.font(size: 20))
                .padding(.trailing, 15)
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
    }
}
