import SwiftUI

struct SBProductByCategoryView: View {
    var category: SBCategory
    
    @Environment(\.dismiss) var dismiss
    @State var products: [SBProduct] = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(Color.black)
                }
                Spacer()
                Text(category.name)
                    .font(R.font.outfitRegular.font(size:16))
                Spacer()
 
            }
            
            .padding()
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(products) { product in
                        SBProductCard(product: product)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.top, 30)
                .padding(.bottom, 50)
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            ProductRepository.shared.fetchProducts(categoryId: category.id) { prodResult in
                if case .success(let prods) = prodResult {
                    products = prods
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
