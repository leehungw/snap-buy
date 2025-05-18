import SwiftUI

struct SBProductManagementView: View {
    @State private var products: [Product] = Product.sampleList
    @State private var isAddPressed = false
    @State private var productToEdit: Product? = nil
    @State private var productToDelete: Product? = nil
    @State private var showDeleteConfirmation = false
    @State private var navigateToEdit = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("Product Management")
                        .font(R.font.outfitMedium.font(size: 24))  // dùng outfitMedium size 24
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.main)
                
                ZStack {
                    if products.isEmpty {
                        Text("No products yet. Tap below to add your first product.")
                            .font(R.font.outfitRegular.font(size: 14))  // outfitRegular size 14
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                            .padding()
                    } else {
                        SBSellerListProduct(
                            products: $products,
                            onRequestDelete: { product in
                                productToDelete = product
                                showDeleteConfirmation = true
                            },
                            onRequestEdit: { product in
                                productToEdit = product
                                navigateToEdit = true
                            }
                        )
                        .padding()
                    }
                    
                    NavigationLink(isActive: $navigateToEdit) {
                        if let product = productToEdit {
                            SBEditProductView(product: product)
                                .onDisappear {
                                    navigateToEdit = false
                                }
                        } else {
                            EmptyView()
                        }
                    } label: {
                        EmptyView()
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NavigationLink(destination: SBAddProductView()) {
                                Image(systemName: isAddPressed ? "plus.circle.fill" : "plus.circle")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.main)
                                    .scaleEffect(isAddPressed ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAddPressed)
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in isAddPressed = true }
                                    .onEnded { _ in isAddPressed = false }
                            )
                            .padding(.trailing, 30)
                            .padding(.bottom, 30)
                        }
                    }
                    
                }
            }
            .navigationBarHidden(true)
        }
        .confirmationDialog("Are you sure you want to delete this product?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let product = productToDelete,
                   let index = products.firstIndex(where: { $0.id == product.id }) {
                    products.remove(at: index)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct SBSellerListProduct: View {
    @Binding var products: [Product]
    var onRequestDelete: (Product) -> Void
    var onRequestEdit: (Product) -> Void
    
    var body: some View {
        ScrollView {
            ForEach(products) { product in
                HStack {
                    Image(product.imageNames[0])
                        .resizable()
                        .frame(width: 70, height: 70)
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(R.font.outfitMedium.font(size: 16))  // outfitMedium size 16
                        
                        Text("$\(product.price, specifier: "%.2f") • Stock: \(product.stock)")
                            .font(R.font.outfitRegular.font(size: 14)) // outfitRegular size 14
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button("Edit") {
                            onRequestEdit(product)
                        }
                        Button("Delete", role: .destructive) {
                            onRequestDelete(product)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .contentShape(Rectangle())
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
    }
}

#Preview {
    SBProductManagementView()
}
