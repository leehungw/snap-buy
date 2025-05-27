import SwiftUI

struct ProductAdmin: Identifiable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let images: [SBProductImage]
    let variants: [SBProductVariant]
    let sellerId: String
    let status: Int
    let quantity: Int
    
    init(from product: SBProduct) {
        self.id = product.id
        self.name = product.name
        self.description = product.description
        self.price = product.basePrice
        self.images = product.productImages
        self.variants = product.productVariants
        self.sellerId = product.sellerId
        self.status = product.status
        self.quantity = product.quantity
    }
}

struct SBAdminProductManagementView: View {
    @State private var searchText: String = ""
    @State private var selectedProduct: SBProduct? = nil
    @State private var showingProductDetail = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var selectedFilter: ProductFilter = .pending
    @Environment(\.dismiss) var dismiss
    
    @State private var approvedProducts: [SBProduct] = []
    @State private var unapprovedProducts: [SBProduct] = []
    
    enum ProductFilter: String, CaseIterable {
        case pending = "Pending"
        case accepted = "Accepted"
    }
    
    private var filteredProducts: [SBProduct] {
        let products = selectedFilter == .pending ? unapprovedProducts : approvedProducts
        return products.filter {
            searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                AdminHeader(title: "Product Management", dismiss: dismiss)
                
                // Search and Filter Section
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search product...", text: $searchText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Filter Picker
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(ProductFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue)
                                .tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                
                if isLoading {
                    Spacer()
                    ProgressView("Loading products...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else if let error = errorMessage {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                        
                        Button(action: {
                            fetchProducts()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Try Again")
                            }
                            .foregroundColor(.blue)
                            .padding()
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredProducts, id: \.id) { product in
                                ProductListItem(
                                    product: product,
                                    isApproved: selectedFilter == .accepted
                                ) {
                                    selectedProduct = product
                                    showingProductDetail = true
                                }
                            }
                        }
                        .padding(.vertical)
                        
                        if filteredProducts.isEmpty {
                            Text("No \(selectedFilter.rawValue.lowercased()) products")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .refreshable {
                        await refreshData()
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $showingProductDetail) {
                if let product = selectedProduct {
                    SBAdminProductDetailSheet(product: product)
                        .onDisappear {
                            fetchProducts() // Refresh when detail sheet is dismissed
                        }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if approvedProducts.isEmpty && unapprovedProducts.isEmpty {
                fetchProducts()
            }
        }
    }
    
    private func refreshData() async {
        await withCheckedContinuation { continuation in
            fetchProducts()
            continuation.resume()
        }
    }
    
    private func fetchProducts() {
        isLoading = true
        errorMessage = nil
        
        let group = DispatchGroup()
        var approvedError: Error?
        var unapprovedError: Error?
        
        group.enter()
        ProductRepository.shared.fetchAcceptedProducts { result in
            switch result {
            case .success(let products):
                self.approvedProducts = products
            case .failure(let error):
                approvedError = error
            }
            group.leave()
        }
        
        group.enter()
        ProductRepository.shared.fetchUnacceptedProducts { result in
            switch result {
            case .success(let products):
                self.unapprovedProducts = products
            case .failure(let error):
                unapprovedError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            
            // Handle errors
            if let approvedError = approvedError, let unapprovedError = unapprovedError {
                // Both requests failed
                self.errorMessage = "Failed to load products:\n- Approved: \(approvedError.localizedDescription)\n- Unapproved: \(unapprovedError.localizedDescription)"
            } else if let approvedError = approvedError {
                // Only approved request failed
                self.errorMessage = "Failed to load approved products: \(approvedError.localizedDescription)"
            } else if let unapprovedError = unapprovedError {
                // Only unapproved request failed
                self.errorMessage = "Failed to load unapproved products: \(unapprovedError.localizedDescription)"
            }
        }
    }
}

struct ProductListItem: View {
    let product: SBProduct
    let isApproved: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                if let firstImage = product.productImages.first {
                    AsyncImage(url: URL(string: firstImage.url)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(R.font.outfitMedium.font(size: 16))
                    Text(formatCurrency(product.basePrice))
                        .font(R.font.outfitRegular.font(size: 14))
                        .foregroundColor(.gray)
                    Text("Stock: \(product.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if !isApproved {
                    Button("View Details") {
                        onTap()
                    }
                    .font(R.font.outfitMedium.font(size: 14))
                    .foregroundColor(.blue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white).shadow(color: .gray.opacity(0.1), radius: 5))
        .padding(.horizontal)
    }
    
}

func formatCurrency(_ amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
}
#Preview {
    SBAdminProductManagementView()
}
