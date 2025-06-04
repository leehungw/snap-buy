import SwiftUI
import Kingfisher

enum ProductStatus: Int, CaseIterable {
    case all = -1
    case pending = 0
    case approved = 1
    case rejected = 2
    
    var title: String {
        switch self {
        case .all: return "All"
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .gray
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        }
    }
}

struct SBProductManagementView: View {
    @State private var products: [SBProduct] = []
    @State private var showAddProduct = false
    @State private var productToEdit: SBProduct? = nil
    @State private var productToDelete: SBProduct? = nil
    @State private var showDeleteConfirmation = false
    @State private var navigateToEdit = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var searchText = ""
    @State private var selectedStatus: ProductStatus? = nil
    
    var filteredProducts: [SBProduct] {
        products.filter { product in
            let matchesSearch = searchText.isEmpty || 
                product.name.localizedCaseInsensitiveContains(searchText)
            let matchesStatus = selectedStatus == nil || 
                product.status == selectedStatus?.rawValue
            return matchesSearch && matchesStatus
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Text("Products")
                                .font(R.font.outfitBold.font(size: 28))
                                .foregroundColor(.main)
                            Spacer()
                            Button(action: { showAddProduct = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                    Text("Add")
                                }
                                .font(R.font.outfitMedium.font(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.main)
                                .cornerRadius(12)
                            }
                        }
                        
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search products...", text: $searchText)
                                .font(R.font.outfitRegular.font(size: 16))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .padding()
                    .background(Color.white)
                    
                    // Filter buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterButton(
                                title: "All",
                                isSelected: selectedStatus == nil,
                                action: { selectedStatus = nil }
                            )
                            
                            ForEach(ProductStatus.allCases.filter { $0 != .all }, id: \.self) { status in
                                FilterButton(
                                    title: status.title,
                                    isSelected: selectedStatus == status,
                                    color: status.color,
                                    action: { selectedStatus = status }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color.white)
                    
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Spacer()
                    } else if let error = errorMessage {
                        Spacer()
                        VStack(spacing: 16) {
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
                        Spacer()
                    } else if filteredProducts.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "cube.box")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text(products.isEmpty ? "No products yet. Tap + to add your first product." : "No products found")
                                .font(R.font.outfitMedium.font(size: 18))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 20),
                                GridItem(.flexible(), spacing: 20)
                            ], spacing: 30) {
                                ForEach(filteredProducts) { product in
                                    ProductCard(
                                        product: product,
                                        onEdit: {
                                            productToEdit = product
                                            navigateToEdit = true
                                        },
                                        onDelete: {
                                            productToDelete = product
                                            showDeleteConfirmation = true
                                        }
                                    )
                                }
                            }
                            .padding(16)
                        }
                        .refreshable {
                            fetchProducts()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddProduct) {
                SBAddProductView(onDismiss: fetchProducts)
            }
            .background(
                NavigationLink(
                    destination: Group {
                        if let product = productToEdit {
                            SBEditProductView(product: product, onDismiss: fetchProducts)
                        }
                    },
                    isActive: $navigateToEdit
                ) { EmptyView() }
            )
            .confirmationDialog(
                "Are you sure you want to delete this product?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let product = productToDelete {
                        deleteProduct(product)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                fetchProducts()
            }
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

struct ProductCard: View {
    let product: SBProduct
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Product Image Container
            ZStack {
                if let firstImage = product.productImages.first {
                    KFImage.url(URL(string: firstImage.url))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width/2 - 50, height: 180)
                        .clipped()
                } else {
                    Color.gray.opacity(0.1)
                }
            }
            .frame(width: UIScreen.main.bounds.width/2 - 50, height: 180)
            .cornerRadius(12)
            
            // Product Info
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(R.font.outfitSemiBold.font(size: 16))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(String(format: "$%.2f", product.basePrice))
                        .font(R.font.outfitBold.font(size: 16))
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: onEdit) {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(.gray)
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                }
                
                HStack {
                    ProductStatusBadge(status: product.status)
                    Spacer()
                    Text("Stock: \(product.quantity)")
                        .font(R.font.outfitRegular.font(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width/2 - 50)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ProductStatusBadge: View {
    let status: Int
    
    var statusInfo: (text: String, color: Color) {
        switch status {
        case ProductStatus.pending.rawValue:
            return (ProductStatus.pending.title, ProductStatus.pending.color)
        case ProductStatus.approved.rawValue:
            return (ProductStatus.approved.title, ProductStatus.approved.color)
        case ProductStatus.rejected.rawValue:
            return (ProductStatus.rejected.title, ProductStatus.rejected.color)
        default:
            return ("Unknown", .gray)
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusInfo.color)
                .frame(width: 6, height: 6)
            Text(statusInfo.text)
                .font(R.font.outfitMedium.font(size: 10))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

//struct FilterButton: View {
//    let title: String
//    let isSelected: Bool
//    var color: Color = .main
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(R.font.outfitMedium.font(size: 14))
//                .foregroundColor(isSelected ? .white : .gray)
//                .padding(.horizontal, 16)
//                .padding(.vertical, 8)
//                .background(
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(isSelected ? color : Color.gray.opacity(0.1))
//                )
//        }
//    }
//}

#Preview {
    SBProductManagementView()
}
