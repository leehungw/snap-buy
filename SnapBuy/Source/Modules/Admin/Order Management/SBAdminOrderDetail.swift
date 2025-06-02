import SwiftUI

struct SBAdminOrderDetail: View {
    let order: SBOrderModel
    @Environment(\.dismiss) var dismiss
    
    @State private var buyer: UserData?
    @State private var seller: UserData?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section(header: Text("Order Information").font(R.font.outfitMedium.font(size: 16))) {
                            Text("Order ID: #\(order.id)")
                                .font(R.font.outfitRegular.font(size: 14))
                            Text("Status: \(order.status)")
                                .font(R.font.outfitRegular.font(size: 14))
                                .foregroundColor(colorForStatus(order.status))
                        }
                        
                        Section(header: Text("Buyer Information").font(R.font.outfitMedium.font(size: 16))) {
                            if let buyer = buyer {
                                HStack {
                                    AsyncImage(url: URL(string: buyer.imageURL)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(buyer.name)
                                            .font(R.font.outfitMedium.font(size: 14))
                                        Text(buyer.email)
                                            .font(R.font.outfitRegular.font(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            Text("Address: \(order.shippingAddress)")
                                .font(R.font.outfitRegular.font(size: 14))
                        }
                        
                        Section(header: Text("Seller Information").font(R.font.outfitMedium.font(size: 16))) {
                            if let seller = seller {
                                HStack {
                                    AsyncImage(url: URL(string: seller.imageURL)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(seller.name)
                                            .font(R.font.outfitMedium.font(size: 14))
                                        Text(seller.email)
                                            .font(R.font.outfitRegular.font(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        Section(header: Text("Order Items").font(R.font.outfitMedium.font(size: 16))) {
                            ForEach(order.orderItems) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top) {
                                        AsyncImage(url: URL(string: item.productImageUrl)) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        } placeholder: {
                                            Color.gray.opacity(0.2)
                                        }
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.productName)
                                                .font(R.font.outfitMedium.font(size: 14))
                                            if !item.productNote.isEmpty {
                                                Text(item.productNote)
                                                    .font(R.font.outfitRegular.font(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                            Text("Quantity: \(item.quantity)")
                                                .font(R.font.outfitRegular.font(size: 12))
                                                .foregroundColor(.gray)
                                            Text("Price: $\(String(format: "%.2f", item.unitPrice))")
                                                .font(R.font.outfitRegular.font(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Order Summary").font(R.font.outfitMedium.font(size: 16))) {
                            HStack {
                                Text("Total Items")
                                    .font(R.font.outfitRegular.font(size: 14))
                                Spacer()
                                Text("\(order.orderItems.count)")
                                    .font(R.font.outfitMedium.font(size: 14))
                            }
                            
                            HStack {
                                Text("Total Amount")
                                    .font(R.font.outfitRegular.font(size: 14))
                                Spacer()
                                Text("$\(String(format: "%.2f", order.totalAmount))")
                                    .font(R.font.outfitMedium.font(size: 14))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            fetchUserDetails()
        }
    }
    
    private func fetchUserDetails() {
        isLoading = true
        
        let group = DispatchGroup()
        
        // Fetch buyer details
        group.enter()
        UserRepository.shared.fetchUserById(userId: order.buyerId) { result in
            switch result {
            case .success(let userData):
                self.buyer = userData
            case .failure(let error):
                print("Failed to fetch buyer: \(error)")
            }
            group.leave()
        }
        
        // Fetch seller details
        group.enter()
        UserRepository.shared.fetchUserById(userId: order.sellerId) { result in
            switch result {
            case .success(let userData):
                self.seller = userData
            case .failure(let error):
                print("Failed to fetch seller: \(error)")
            }
            group.leave()
        }
        
        // When both fetches are complete
        group.notify(queue: .main) {
            isLoading = false
        }
    }
    
    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case OrderStatus.pending.rawValue:
            return .orange
        case OrderStatus.inProgress.rawValue:
            return .blue
        case OrderStatus.success.rawValue:
            return .green
        case OrderStatus.delivered.rawValue:
            return .purple
        case OrderStatus.cancelled.rawValue:
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    SBAdminOrderDetail(order: SBOrderModel(
        id: "ORD-123",
        buyerId: "BUYER-123",
        sellerId: "SELLER-123",
        totalAmount: 99.99,
        shippingAddress: "123 Main St",
        orderItems: [],
        status: "Pending"
    ))
}


