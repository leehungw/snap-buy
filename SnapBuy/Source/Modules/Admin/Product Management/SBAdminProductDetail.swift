import SwiftUI

struct SBAdminProductDetailSheet: View {
    let product: SBProduct
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var seller: UserData? = nil
    @State private var showSuccessAlert = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !product.productImages.isEmpty {
                        TabView {
                            ForEach(product.productImages, id: \.id) { image in
                                AsyncImage(url: URL(string: image.url)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                            }
                        }
                        .frame(height: 300)
                        .tabViewStyle(PageTabViewStyle())
                    }

                    // Product Info Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text(product.name)
                            .font(R.font.outfitMedium.font(size: 22))

                        Text(formatCurrency(product.basePrice))
                            .font(R.font.outfitMedium.font(size: 18))
                            .foregroundColor(.blue)
                            
                        Text("Stock: \(product.quantity)")
                            .font(R.font.outfitRegular.font(size: 14))
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Description Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(R.font.outfitBold.font(size: 16))

                        Text(product.description)
                            .font(R.font.outfitRegular.font(size: 14))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Variants Section
                    if !product.productVariants.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Variants")
                                .font(R.font.outfitBold.font(size: 16))
                            
                            ForEach(product.productVariants, id: \.id) { variant in
                                HStack {
                                    Text("\(variant.color) - \(variant.size)")
                                    Spacer()
                                    Text(formatCurrency(variant.price))
                                }
                                .font(R.font.outfitRegular.font(size: 14))
                            }
                        }
                    }

                    Divider()

                    // Seller Information Section
                    if let seller = seller {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Seller Information")
                                .font(R.font.outfitBold.font(size: 16))
                            
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: seller.imageURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(seller.name)
                                        .font(R.font.outfitMedium.font(size: 16))
                                    Text(seller.email)
                                        .font(R.font.outfitRegular.font(size: 14))
                                        .foregroundColor(.secondary)
                                    Text("@\(seller.userName)")
                                        .font(R.font.outfitRegular.font(size: 12))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    if seller.isPremium {
                                        Label("Premium", systemImage: "star.fill")
                                            .font(R.font.outfitMedium.font(size: 12))
                                            .foregroundColor(.yellow)
                                    }
                                    if seller.isBanned {
                                        Label("Banned", systemImage: "exclamationmark.triangle.fill")
                                            .font(R.font.outfitMedium.font(size: 12))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }

                    // Approval Buttons
                    HStack(spacing: 20) {
                        Button(action: { handleApproval(approve: true) }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Approve")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading)
                        
                        Button(action: { handleApproval(approve: false) }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Reject")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading)
                    }
                    .padding(.top)
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Product Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Product has been approved successfully")
        }
        .onAppear {
            fetchSellerInfo()
        }
    }
    
    private func handleApproval(approve: Bool) {
        isLoading = true
        errorMessage = nil
        
        if approve {
            ProductRepository.shared.approveProduct(productId: product.id) { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let response):
                        if response.result == 1 {
                            print("✅ Approve thành công")
                            self.showSuccessAlert = true
                        } else if let error = response.error {
                            self.errorMessage = error.message
                        }
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        } else {
            dismiss()
        }
    }

    private func fetchSellerInfo() {
        ProductRepository.shared.fetchSellerInfo(userId: product.sellerId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.seller = user
                case .failure(let error):
                    self.errorMessage = "Failed to load seller info: \(error.localizedDescription)"
                }
            }
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}

#Preview {
    SBAdminProductDetailSheet(
        product: SBProduct(
            id: 1,
            sellerId: "seller1",
            name: "Sample Product",
            description: "A sample product description",
            basePrice: 99.99,
            status: 0,
            categoryId: 1,
            quantity: 10,
            createdAt: "",
            updatedAt: "",
            productImages: [],
            productVariants: [],
            listTag: []
        )
    )
}
