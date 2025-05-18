import SwiftUI

struct SBProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(product.imageNames[0])
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
            Text(product.brand)
                .font(R.font.outfitMedium.font(size: 14))
                .foregroundColor(.gray)
            Text(String(format: "$%.2f", product.price))
                .font(R.font.outfitBold.font(size: 18))
        }
    }
}

#Preview {
    SBProductCard(product: Product.sampleList[0])
}
