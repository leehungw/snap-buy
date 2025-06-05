import SwiftUI

struct SBOrderDetailSheet: View {
    let order: SBOrderModel
    @Environment(\.dismiss) var dismiss
    
    @State private var seller: UserData?
    @State private var isLoadingSeller = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Order Status
                    HStack {
                        Text("Order Status")
                            .font(R.font.outfitMedium.font(size: 16))
                        Spacer()
                        Text(order.status)
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Seller Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Seller Information")
                            .font(R.font.outfitMedium.font(size: 16))
                        
                        if isLoadingSeller {
                            ProgressView()
                        } else if let seller = seller {
                            HStack {
                                AsyncImage(url: URL(string: seller.imageURL ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(seller.name)
                                        .font(R.font.outfitSemiBold.font(size: 14))
                                    Text(seller.email)
                                        .font(R.font.outfitRegular.font(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Order Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Items")
                            .font(R.font.outfitMedium.font(size: 16))
                        
                        ForEach(order.orderItems) { item in
                            HStack(spacing: 12) {
                                AsyncImage(url: URL(string: item.productImageUrl)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.productName)
                                        .font(R.font.outfitSemiBold.font(size: 14))
                                    if !item.productNote.isEmpty {
                                        Text("Note: \(item.productNote)")
                                            .font(R.font.outfitRegular.font(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    HStack {
                                        Text("Quantity: \(item.quantity)")
                                            .font(R.font.outfitRegular.font(size: 12))
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("$\(String(format: "%.2f", item.unitPrice))")
                                            .font(R.font.outfitSemiBold.font(size: 14))
                                    }
                                    HStack {
                                        Image(systemName: item.isReviewed ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(item.isReviewed ? .green : .orange)
                                        Text(item.isReviewed ? "Reviewed" : "Not Reviewed")
                                            .font(R.font.outfitRegular.font(size: 12))
                                            .foregroundColor(item.isReviewed ? .green : .orange)
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Shipping Address
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Shipping Address")
                            .font(R.font.outfitMedium.font(size: 16))
                        Text(order.shippingAddress)
                            .font(R.font.outfitRegular.font(size: 14))
                            .foregroundColor(.gray)
                        Text("Phone: \(order.phoneNumber)")
                            .font(R.font.outfitRegular.font(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Order Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Summary")
                            .font(R.font.outfitMedium.font(size: 16))
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Subtotal")
                                    .font(R.font.outfitRegular.font(size: 14))
                                Spacer()
                                Text("$\(String(format: "%.2f", calculateSubtotal()))")
                                    .font(R.font.outfitSemiBold.font(size: 14))
                            }
                            
                            HStack {
                                Text("Shipping Fee")
                                    .font(R.font.outfitRegular.font(size: 14))
                                Spacer()
                                Text("$\(String(format: "%.2f", calculateShippingFee()))")
                                    .font(R.font.outfitSemiBold.font(size: 14))
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total")
                                    .font(R.font.outfitSemiBold.font(size: 16))
                                Spacer()
                                Text("$\(String(format: "%.2f", order.totalAmount))")
                                    .font(R.font.outfitBold.font(size: 16))
                                    .foregroundColor(.main)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Order Detail")
                        .font(R.font.outfitRegular.font(size: 16))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .onAppear {
            fetchSellerInfo()
        }
    }
    
    private func fetchSellerInfo() {
        UserRepository.shared.fetchUserById(userId: order.sellerId) { result in
            isLoadingSeller = false
            switch result {
            case .success(let userData):
                self.seller = userData
            case .failure:
                self.seller = nil
            }
        }
    }
    
    private func calculateSubtotal() -> Double {
        order.orderItems.reduce(0) { $0 + ($1.unitPrice * Double($1.quantity)) }
    }
    
    private func calculateShippingFee() -> Double {
        // Assuming shipping fee is the difference between total and subtotal
        order.totalAmount - calculateSubtotal()
    }
}

