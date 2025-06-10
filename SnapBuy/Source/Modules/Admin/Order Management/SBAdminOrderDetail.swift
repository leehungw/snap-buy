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
                        // Order Status Section
                        Section(header: Text("Order Status").font(R.font.outfitMedium.font(size: 16))) {
                            HStack {
                                Image(systemName: statusIcon(order.status))
                                Text(order.status)
                                Spacer()
                            }
                            .font(R.font.outfitMedium.font(size: 16))
                            .foregroundColor(colorForStatus(order.status))
                            .padding(.vertical, 4)
                        }
                        
                        Section(header: Text("Order Information").font(R.font.outfitMedium.font(size: 16))) {
                            HStack {
                                Text("Order ID")
                                Spacer()
                                Text("#\(order.id)")
                                    .foregroundColor(.gray)
                            }
                            .font(R.font.outfitRegular.font(size: 14))
                            
                            HStack {
                                Text("Total Amount")
                                Spacer()
                                Text("$\(String(format: "%.2f", order.totalAmount))")
                                    .foregroundColor(.green)
                                    .fontWeight(.semibold)
                            }
                            .font(R.font.outfitRegular.font(size: 14))
                            
                           
                        }
                        
                        Section(header: Text("Shipping Address").font(R.font.outfitMedium.font(size: 16))) {
                            Text(order.shippingAddress)
                                .font(R.font.outfitRegular.font(size: 14))
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(.gray)
                            HStack {
                                Text("Phone Number")
                                Spacer()
                                Text(order.phoneNumber)
                                    .foregroundColor(.gray)
                            }
                            .font(R.font.outfitRegular.font(size: 14))
                        }
                        
                        Section(header: Text("Buyer Information").font(R.font.outfitMedium.font(size: 16))) {
                            if let buyer = buyer {
                                HStack {
                                    AsyncImage(url: URL(string: buyer.imageURL)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 40, height: 40)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        case .failure(_):
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            Color.gray.opacity(0.2)
                                        }
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(buyer.name)
                                            .font(R.font.outfitMedium.font(size: 14))
                                        Text(buyer.email)
                                            .font(R.font.outfitRegular.font(size: 12))
                                            .foregroundColor(.gray)
                                        Text("@\(buyer.userName)")
                                            .font(R.font.outfitRegular.font(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        if buyer.isPremium {
                                            Label("Premium", systemImage: "star.fill")
                                                .font(.caption)
                                                .foregroundColor(.yellow)
                                        }
                                        if buyer.isBanned {
                                            Label("Banned", systemImage: "exclamationmark.triangle.fill")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            } else {
                                Text("Loading buyer information...")
                                    .font(R.font.outfitRegular.font(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Section(header: Text("Seller Information").font(R.font.outfitMedium.font(size: 16))) {
                            if let seller = seller {
                                HStack {
                                    AsyncImage(url: URL(string: seller.imageURL)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 40, height: 40)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        case .failure(_):
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            Color.gray.opacity(0.2)
                                        }
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(seller.name)
                                            .font(R.font.outfitMedium.font(size: 14))
                                        Text(seller.email)
                                            .font(R.font.outfitRegular.font(size: 12))
                                            .foregroundColor(.gray)
                                        Text("@\(seller.userName)")
                                            .font(R.font.outfitRegular.font(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                }
                                .padding(.vertical, 4)
                            } else {
                                Text("Loading seller information...")
                                    .font(R.font.outfitRegular.font(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Section(header: Text("Order Items (\(order.orderItems.count))").font(R.font.outfitMedium.font(size: 16))) {
                            ForEach(order.orderItems) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top, spacing: 12) {
                                        AsyncImage(url: URL(string: item.productImageUrl)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 60, height: 60)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            case .failure(_):
                                                Image(systemName: "photo")
                                                    .foregroundColor(.gray)
                                                    .frame(width: 60, height: 60)
                                            @unknown default:
                                                Color.gray.opacity(0.2)
                                                    .frame(width: 60, height: 60)
                                            }
                                        }
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.productName)
                                                .font(R.font.outfitMedium.font(size: 14))
                                                .lineLimit(2)
                                            
                                            if !item.productNote.isEmpty {
                                                Text(item.productNote)
                                                    .font(R.font.outfitRegular.font(size: 12))
                                                    .foregroundColor(.gray)
                                                    .lineLimit(1)
                                            }
                                            
                                            HStack {
                                                Text("Qty: \(item.quantity)")
                                                    .font(R.font.outfitRegular.font(size: 12))
                                                    .foregroundColor(.gray)
                                                
                                                Spacer()
                                                
                                                Text("$\(String(format: "%.2f", item.unitPrice))")
                                                    .font(R.font.outfitSemiBold.font(size: 14))
                                                    .foregroundColor(.green)
                                            }
                                            
                                            Text("Total: $\(String(format: "%.2f", Double(item.quantity) * item.unitPrice))")
                                                .font(R.font.outfitMedium.font(size: 12))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
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
                                Text("Subtotal")
                                    .font(R.font.outfitRegular.font(size: 14))
                                Spacer()
                                Text("$\(String(format: "%.2f", order.totalAmount))")
                                    .font(R.font.outfitMedium.font(size: 14))
                            }
                            
                            HStack {
                                Text("Total Amount")
                                    .font(R.font.outfitBold.font(size: 16))
                                Spacer()
                                Text("$\(String(format: "%.2f", order.totalAmount))")
                                    .font(R.font.outfitBold.font(size: 16))
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
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
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    self.buyer = userData
                case .failure(let error):
                    print("Failed to fetch buyer: \(error)")
                }
                group.leave()
            }
        }
        
        // Fetch seller details
        group.enter()
        UserRepository.shared.fetchUserById(userId: order.sellerId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    self.seller = userData
                case .failure(let error):
                    print("Failed to fetch seller: \(error)")
                }
                group.leave()
            }
        }
        
        // When both fetches are complete
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case OrderStatus.pending.rawValue:
            return .orange
        case OrderStatus.approve.rawValue:
            return .blue
        case OrderStatus.success.rawValue:
            return .green
        case OrderStatus.failed.rawValue:
            return .red
        default:
            return .gray
        }
    }
    
    private func statusIcon(_ status: String) -> String {
        switch status {
        case OrderStatus.pending.rawValue:
            return "clock"
        case OrderStatus.approve.rawValue:
            return "checkmark.circle"
        case OrderStatus.success.rawValue:
            return "checkmark.circle.fill"
        case OrderStatus.failed.rawValue:
            return "xmark.circle"
        default:
            return "questionmark.circle"
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
        phoneNumber: "0123456789",
        orderItems: [],
        status: "Pending"
    ))
}


