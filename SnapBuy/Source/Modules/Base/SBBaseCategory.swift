import SwiftUI
import Kingfisher

struct SBCategoryItemView: View {
    let category: SBCategory
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(URL(string: category.imageUrl))
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .offset(
                    x: 70,
                    y: category.name == "Shoes" ? -100 :
                        category.name == "Accessories" ? 160 : 80
                )
                .clipped()
                .scaleEffect(1.5)
            
            
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                Text(category.name)
                    .font(R.font.outfitBold.font(size:17))
                    .foregroundColor(.black)
                Text("\(category.numberOfProduct) Product")
                    .font(R.font.outfitRegular.font(size:13))
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.leading,40)
            .cornerRadius(10)
            .padding(8)
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
