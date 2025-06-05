import SwiftUI

class OrderDetailViewModel: ObservableObject {
    @Published var order: SBOrderModel?
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchOrderDetail(orderId: String) {
        isLoading = true
        error = nil
        
        OrderRepository.shared.getOrderDetail(orderId: orderId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let order):
                    self?.order = order
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func updateOrderStatus(status: String) {
        guard let orderId = order?.id else { return }
        isLoading = true
        error = nil
        
        OrderRepository.shared.updateOrderStatus(orderId: orderId, status: status) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let updatedOrder):
                    self?.order = updatedOrder
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}

struct OrderDetailView: View {
    let orderId: String
    @StateObject private var viewModel = OrderDetailViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showAllItems = false
    @State private var showErrorAlert = false

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.main)
                    }
                    
                    Text("Order Details")
                        .font(R.font.outfitBold.font(size: 20))
                        .foregroundColor(.main)
                    
                    Spacer()
                }
                .padding()
                .background(Color.white)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let order = viewModel.order {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Status Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Order Status")
                                    .font(R.font.outfitBold.font(size: 18))
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("#\(order.id)")
                                            .font(R.font.outfitMedium.font(size: 14))
                                            .foregroundColor(.gray)
                                        Text(formatDate(from: order.id))
                                            .font(R.font.outfitRegular.font(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Menu {
                                        ForEach(OrderStatus.allCases, id: \.self) { status in
                                            Button(status.rawValue) {
                                                viewModel.updateOrderStatus(status: status.rawValue)
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Circle()
                                                .fill(colorForStatus(order.status))
                                                .frame(width: 8, height: 8)
                                            Text(order.status)
                                                .font(R.font.outfitMedium.font(size: 14))
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(colorForStatus(order.status).opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            // Buyer Information
                            InfoCard(title: "Buyer Information") {
                                VStack(alignment: .leading, spacing: 12) {
                                    InfoRow(icon: "person.circle", title: "ID", value: order.buyerId)
                                    InfoRow(icon: "location", title: "Address", value: order.shippingAddress)
                                    InfoRow(icon: "phone", title: "Phone", value: order.phoneNumber)
                                }
                            }
                            
                            // Order Items
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Order Items")
                                    .font(R.font.outfitBold.font(size: 18))
                                    .padding(.horizontal)
                                
                                let displayedItems = showAllItems ? order.orderItems : Array(order.orderItems.prefix(2))
                                
                                ForEach(displayedItems) { item in
                                    OrderItemCard(item: item)
                                }
                                
                                if order.orderItems.count > 2 && !showAllItems {
                                    Button(action: { showAllItems = true }) {
                                        HStack {
                                            Text("Show More Items")
                                                .font(R.font.outfitMedium.font(size: 14))
                                            Image(systemName: "chevron.down")
                                        }
                                        .foregroundColor(.main)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            
                            // Order Summary
                            InfoCard(title: "Order Summary") {
                                VStack(spacing: 16) {
                                    InfoRow(
                                        icon: "cart",
                                        title: "Total Items",
                                        value: "\(order.orderItems.count)",
                                        valueColor: .primary
                                    )
                                    
                                    Divider()
                                    
                                    InfoRow(
                                        icon: "dollarsign.circle",
                                        title: "Total Amount",
                                        value: String(format: "$%.2f", order.totalAmount),
                                        valueColor: .green
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.error ?? "Unknown error occurred")
        }
        .onChange(of: viewModel.error) { newValue in
            showErrorAlert = newValue != nil
        }
        .onAppear {
            viewModel.fetchOrderDetail(orderId: orderId)
        }
    }
    
    private func formatDate(from orderId: String) -> String {
        // Implement date formatting based on your orderId format
        return "Today at 10:30 AM" // Placeholder
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(R.font.outfitBold.font(size: 18))
            content()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .gray
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                Text(title)
                    .font(R.font.outfitMedium.font(size: 14))
            }
            Spacer()
            Text(value)
                .font(R.font.outfitMedium.font(size: 14))
                .foregroundColor(valueColor)
        }
    }
}

struct OrderItemCard: View {
    let item: SBOrderItemModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: item.productImageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.productName)
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .lineLimit(2)
                    
                    if !item.productNote.isEmpty {
                        Text(item.productNote)
                            .font(R.font.outfitRegular.font(size: 14))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    HStack {
                        Text("Qty: \(item.quantity)")
                            .font(R.font.outfitRegular.font(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(String(format: "$%.2f", item.unitPrice))
                            .font(R.font.outfitMedium.font(size: 14))
                            .foregroundColor(.green)
                    }
                }
            }
            
            if !item.productNote.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Note:")
                        .font(R.font.outfitMedium.font(size: 14))
                        .foregroundColor(.gray)
                    Text(item.productNote)
                        .font(R.font.outfitRegular.font(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    OrderDetailView(orderId: "1")
}
