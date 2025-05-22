import SwiftUI

struct SBAdminProductDetailSheet: View {
    let product: ProductAdmin
    let onApproveToggle: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AutoImageCarouselView(images: product.productInformation.imageNames)

                    // Product Info Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text(product.productInformation.name)
                            .font(R.font.outfitMedium.font(size: 22))

                        labeledText(label: "Brand", value: product.productInformation.brand)
                        labeledText(label: "Category", value: product.productInformation.category)
                        labeledText(label: "Price", value: formatCurrency(product.productInformation.price))
                        labeledText(label: "Stock", value: "\(product.productInformation.stock)")
                    }

                    Divider()

                    // Description Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(R.font.outfitBold.font(size: 16))

                        Text(product.productInformation.description)
                            .font(R.font.outfitRegular.font(size: 14))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Colors & Sizes
                    if !product.productInformation.colors.isEmpty {
                        labeledText(label: "Available Colors", value: product.productInformation.colors.joined(separator: ", "))
                    }

                    if !product.productInformation.sizes.isEmpty {
                        labeledText(label: "Available Sizes", value: product.productInformation.sizes.joined(separator: ", "))
                    }

                    Divider()

                    // Seller Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Seller Information")
                            .font(R.font.outfitBold.font(size: 16))

                        labeledText(label: "Name", value: product.sellerName)
                        labeledText(label: "Email", value: product.sellerEmail)
                    }

                    // Approval Toggle
                    Button(action: {
                        onApproveToggle()
                    }) {
                        HStack {
                            Image(systemName: product.isApproved ? "checkmark.seal.fill" : "clock.fill")
                                .foregroundColor(product.isApproved ? .blue : .orange)
                            Text(product.isApproved ? "Approved" : "Pending Approval")
                                .font(R.font.outfitMedium.font(size: 14))
                                .foregroundColor(product.isApproved ? .blue : .orange)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(product.isApproved ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Product Detail")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func labeledText(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .font(R.font.outfitMedium.font(size: 14))
                .foregroundColor(.primary)
            Text(value)
                .font(R.font.outfitRegular.font(size: 14))
                .foregroundColor(.secondary)
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
        product: ProductAdmin(
            productInformation: Product(
                id: UUID(),
                name: "Vintage Jacket",
                brand: "RetroStyle",
                price: 89.99,
                stock: 15,
                imageNames: ["ver_1","ver_2","ver_3","ver_4"],
                category: "Jackets",
                colors: ["Red", "Black"],
                sizes: ["S", "M", "L"],
                description: "A stylish vintage jacket perfect for fall."
            ),
            isApproved: false,
            sellerName: "John Doe",
            sellerEmail: "john@example.com"
        ),
        onApproveToggle: {}
    )
}
