import SwiftUI

struct ProductAdmin: Identifiable {
    var id: UUID { productInformation.id }
    let productInformation: Product
    var isApproved: Bool
    let sellerName: String
    let sellerEmail: String
}

struct SBAdminProductManagementView: View {
    @State private var searchText: String = ""
    @State private var showOnlyApproved: Bool = false
    @State private var selectedProduct: ProductAdmin? = nil
    @Environment(\.dismiss) var dismiss

    @State private var products: [ProductAdmin] = [
        ProductAdmin(
            productInformation: Product(
                id: UUID(),
                name: "T-Shirt",
                brand: "CoolBrand",
                price: 25000,
                stock: 10,
                imageNames: ["tshirt"],
                category: "Clothes",
                colors: ["Red", "Blue"],
                sizes: ["M", "L"],
                description: "Comfortable cotton T-shirt"
            ),
            isApproved: true,
            sellerName: "Minh Le",
            sellerEmail: "minh@example.com"
        ),
        ProductAdmin(
            productInformation: Product(
                id: UUID(),
                name: "Sneakers",
                brand: "FastFoot",
                price: 100000,
                stock: 5,
                imageNames: ["sneakers"],
                category: "Shoes",
                colors: ["Black"],
                sizes: ["42", "43"],
                description: "Stylish sneakers"
            ),
            isApproved: false,
            sellerName: "Bao Tran",
            sellerEmail: "bao@example.com"
        ),
        ProductAdmin(
            productInformation: Product(
                id: UUID(),
                name: "Jacket",
                brand: "WarmStyle",
                price: 150000,
                stock: 7,
                imageNames: ["jacket"],
                category: "Clothes",
                colors: ["Green"],
                sizes: ["M", "L", "XL"],
                description: "Warm and cozy jacket"
            ),
            isApproved: true,
            sellerName: "Huy Nguyen",
            sellerEmail: "huy@example.com"
        )
    ]

    private var filteredProducts: [ProductAdmin] {
        products.filter {
            (!showOnlyApproved || $0.isApproved) &&
            (searchText.isEmpty || $0.productInformation.name.lowercased().contains(searchText.lowercased()))
        }
    }

    var body: some View {
        NavigationView {
                VStack(spacing: 20) {
                    AdminHeader(title: "Product Management", dismiss: dismiss)

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
                    .padding(.horizontal)

                    // Toggle
                    Toggle(isOn: $showOnlyApproved) {
                        Text("Show only approved products")
                            .font(R.font.outfitRegular.font(size: 14))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .padding(.horizontal)
                    ScrollView {
                    // Product List
                    if filteredProducts.isEmpty {
                        Text("No products found.")
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    } else {
                        VStack {
                            ForEach(filteredProducts) { product in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 16) {
                                        if let imageName = product.productInformation.imageNames.first {
                                            Image(imageName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .cornerRadius(12)
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(product.productInformation.name)
                                                .font(R.font.outfitMedium.font(size: 16))
                                            Text(formatCurrency(product.productInformation.price))
                                                .font(R.font.outfitRegular.font(size: 14))
                                                .foregroundColor(.gray)
                                            Text("Seller: \(product.sellerName)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(product.sellerEmail)
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 6) {
                                            Label(product.isApproved ? "Approved" : "Pending", systemImage: "checkmark.shield")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                                .padding(6)
                                                .background(product.isApproved ? Color.blue : Color.orange)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white).shadow(color: .gray.opacity(0.1), radius: 5))
                                .padding(.horizontal)
                                .onTapGesture {
                                    selectedProduct = product
                                }
                                .sheet(item: $selectedProduct) { product in
                                    SBAdminProductDetailSheet(product: product, onApproveToggle: {
                                        toggleApproval(for: product)
                                    })
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            
        }
        .navigationBarBackButtonHidden(true)
    }

    private func toggleApproval(for product: ProductAdmin) {
        if let index = products.firstIndex(where: { $0.productInformation.id == product.productInformation.id }) {
            products[index].isApproved.toggle()
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
    SBAdminProductManagementView()
}
