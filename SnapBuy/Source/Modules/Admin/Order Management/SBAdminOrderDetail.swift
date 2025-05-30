import SwiftUI

struct SBAdminOrderDetail: View {
    let order: SBOrderModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Order Information").font(R.font.outfitMedium.font(size: 16))) {
                    Text("Order ID: #\(order.id)")
                        .font(R.font.outfitRegular.font(size: 14))
                    Text("Status: \(order.status)")
                        .font(R.font.outfitRegular.font(size: 14))
                        .foregroundColor(colorForStatus(order.status))
                }
                
                Section(header: Text("Buyer Information").font(R.font.outfitMedium.font(size: 16))) {
                    Text("Buyer ID: \(order.buyerId)")
                        .font(R.font.outfitRegular.font(size: 14))
                    Text("Address: \(order.shippingAddress)")
                        .font(R.font.outfitRegular.font(size: 14))
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
    }
    
    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case OrderStatus.pending.rawValue:
            return .orange
        case OrderStatus.inProgress.rawValue:
            return .blue
        case OrderStatus.complete.rawValue:
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


