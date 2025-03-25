import SwiftUI

struct CategoryItemView: View {
    let category: Category

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(category.imageName)
                .resizable()
                .scaledToFill()
                .scaleEffect(
                    1.5
                )

                .frame(height: 120)
                .offset(
                    x: 70,
                    y: category.title == "Shoes" ? -100 :
                    category.title == "Accessories" ? 160 : 80
                )
                .clipped()

            
            
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                Text(category.title)
                    .font(.custom("Outfit-Bold", size: 17))
                    .foregroundColor(.black)
                Text("\(category.productCount) Product")
                    .font(.custom("Outfit-Regular", size: 13))
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

#Preview {
    CategoryItemView(category: .samples[3])
}
