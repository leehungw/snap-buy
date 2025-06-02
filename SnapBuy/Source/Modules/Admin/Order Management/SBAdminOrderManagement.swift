import SwiftUI

struct SBAdminOrderManagement: View {
    @State private var orders: [SBOrderModel] = []
    @State private var searchText = ""
    @State private var selectedStatus: String? = nil
    @State private var showingOrderDetail: SBOrderModel? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) var dismiss
    
    var filteredOrders: [SBOrderModel] {
        orders.filter { order in
            if searchText.isEmpty {
                return true
            }
            return order.id.localizedCaseInsensitiveContains(searchText) ||
                   order.buyerId.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                AdminHeader(title: "Order Management", dismiss: dismiss)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by Order ID or Buyer ID", text: $searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 1))
                .background(Color.white)
                .padding(.horizontal)
                
                // Status Filter
                Picker("Filter Status", selection: $selectedStatus) {
                    Text("All").tag(String?.none)
                    ForEach(OrderStatus.allValues, id: \.self) { status in
                        Text(status).tag(Optional(status))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: selectedStatus) { newStatus in
                    loadOrders()
                }

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack {
                        Text("Error loading orders")
                            .font(.headline)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Button("Try Again") {
                            loadOrders()
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if orders.isEmpty {
                    Text("No orders found")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredOrders) { order in
                        Button {
                            showingOrderDetail = order
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Order #\(order.id)")
                                        .font(R.font.outfitMedium.font(size: 16))
                                    Spacer()
                                    Text(order.status)
                                        .font(R.font.outfitMedium.font(size: 14))
                                        .foregroundColor(colorForStatus(order.status))
                                        .padding(6)
                                        .background(colorForStatus(order.status).opacity(0.2))
                                        .cornerRadius(6)
                                }
                                
                                Text("Buyer ID: \(order.buyerId)")
                                    .font(R.font.outfitRegular.font(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text(order.shippingAddress)
                                    .font(R.font.outfitRegular.font(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text("\(order.orderItems.count) items • $\(String(format: "%.2f", order.totalAmount))")
                                    .font(R.font.outfitRegular.font(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .onAppear {
                loadOrders()
            }
            .sheet(item: $showingOrderDetail) { order in
                SBAdminOrderDetail(order: order)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func loadOrders() {
        isLoading = true
        errorMessage = nil
        
        if let status = selectedStatus {
            // Fetch orders by status
            OrderRepository.shared.fetchOrdersByStatus(status: status) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let fetchedOrders):
                        self.orders = fetchedOrders
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        print("Failed to load orders: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Fetch all orders
            OrderRepository.shared.fetchAllOrders { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let fetchedOrders):
                        self.orders = fetchedOrders
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        print("Failed to load orders: \(error.localizedDescription)")
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
    SBAdminOrderManagement()
}
