import SwiftUI
import Kingfisher

struct SBProductManagementView: View {
    @State private var products: [SBProduct] = []
    @State private var isAddPressed = false
    @State private var productToEdit: SBProduct? = nil
    @State private var productToDelete: SBProduct? = nil
    @State private var showDeleteConfirmation = false
    @State private var navigateToEdit = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("Product Management")
                        .font(R.font.outfitMedium.font(size: 24))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.main)
                
                ZStack {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = errorMessage {
                        VStack {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                fetchProducts()
                            }
                            .padding()
                            .background(Color.main)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                    } else if products.isEmpty {
                        Text("No products yet. Tap below to add your first product.")
                            .font(R.font.outfitRegular.font(size: 14))
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
                            SBEditProductView(product: product, onDismiss: fetchProducts)
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
                            NavigationLink(destination: SBAddProductView(onDismiss: fetchProducts)) {
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
            .onAppear(perform: fetchProducts)
        }
        .confirmationDialog("Are you sure you want to delete this product?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let product = productToDelete {
                    deleteProduct(product)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func fetchProducts() {
        isLoading = true
        errorMessage = nil
        
        guard let sellerId = UserRepository.shared.currentUser?.id else {
            errorMessage = "User not found"
            isLoading = false
            return
        }
        
        ProductRepository.shared.fetchAllProductsBySellerId(sellerId: sellerId) { result in
            isLoading = false
            switch result {
            case .success(let fetchedProducts):
                products = fetchedProducts
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func deleteProduct(_ product: SBProduct) {
        isLoading = true
        errorMessage = nil
        
        ProductRepository.shared.deleteProduct(productId: product.id) { result in
            isLoading = false
            switch result {
            case .success:
                if let index = products.firstIndex(where: { $0.id == product.id }) {
                    products.remove(at: index)
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct SBSellerListProduct: View {
    @Binding var products: [SBProduct]
    var onRequestDelete: (SBProduct) -> Void
    var onRequestEdit: (SBProduct) -> Void
    
    var body: some View {
        ScrollView {
            ForEach(products) { product in
                HStack {
                    if let firstImage = product.productImages.first {
                        KFImage.init(URL(string: firstImage.url))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(product.name)
                                .font(R.font.outfitMedium.font(size: 16))
                            
                            // Status Badge
                            StatusBadge(status: product.status)
                        }
                        
                        Text("$\(product.basePrice, specifier: "%.2f") • Stock: \(product.quantity)")
                            .font(R.font.outfitRegular.font(size: 14))
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

struct StatusBadge: View {
    let status: Int
    
    var statusInfo: (text: String, color: Color) {
        switch status {
        case 0:
            return ("Pending", .orange)
        case 1:
            return ("Approved", .green)
        default:
            return ("Unknown", .gray)
        }
    }
    
    var body: some View {
        Text(statusInfo.text)
            .font(R.font.outfitRegular.font(size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusInfo.color)
            .cornerRadius(12)
    }
}

#Preview {
    SBProductManagementView()
}
