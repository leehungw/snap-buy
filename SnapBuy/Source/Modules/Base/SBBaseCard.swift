import SwiftUI
import Kingfisher

struct SBProductCard: View {
    let product: SBProduct
    @State private var isActive = false

    var body: some View {
        ZStack {
            NavigationLink(
                destination: SBProductDetailView(product: product),
                isActive: $isActive,
                label: { EmptyView() }
            )
            .hidden()

            VStack(alignment: .center, spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    KFImage(URL(string: product.productImages.first?.url ?? ""))
                        .resizable()
                        .scaledToFit()
                        .clipped()
                    Image(systemName: "heart")
                        .padding(8)
                        .foregroundColor(.white)
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Circle())
                        .shadow(radius: 1)
                        .padding(6)
                }
                .frame(width: 170, height: 190)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3)
                Text(product.name)
                    .padding(.top, 15)
                    .font(R.font.outfitBold.font(size: 18))
                    .fontWeight(.semibold)
                Text(product.listTag.first ?? "")
                    .font(R.font.outfitMedium.font(size: 14))
                    .foregroundColor(.gray)
                Text(String(format: "$%.2f", product.basePrice))
                    .font(R.font.outfitBold.font(size: 18))
                Spacer()
            }
            .onTapGesture {
                isActive = true
            }
        }
    }
}

