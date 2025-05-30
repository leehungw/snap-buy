import SwiftUI

class OrderManagementViewModel: ObservableObject {
    @Published var orders: [SBOrderModel] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var selectedStatus: String? = nil
    
    var filteredOrders: [SBOrderModel] {
        if let status = selectedStatus {
            return orders.filter { $0.status == status }
        }
        return orders
    }
    
    func fetchOrders() {
        isLoading = true
        error = nil
        
        guard let sellerId = UserRepository.shared.currentUser?.id else {
            error = "User not logged in"
            isLoading = false
            return
        }
        
        OrderRepository.shared.fetchListSellerOrders(sellerId: sellerId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let orders):
                    self?.orders = orders
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func updateOrderStatus(orderId: String, status: String) {
        OrderRepository.shared.updateOrderStatus(orderId: orderId, status: status) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedOrder):
                    if let index = self?.orders.firstIndex(where: { $0.id == orderId }) {
                        self?.orders[index] = updatedOrder
                    }
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}

struct SBOrderManagementView: View {
    @StateObject private var viewModel = OrderManagementViewModel()
    @State private var showErrorAlert = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Text("Order Management")
                        .font(R.font.outfitMedium.font(size: 24))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.main)

                // Filter buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        Button("All") {
                            viewModel.selectedStatus = nil
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(viewModel.selectedStatus == nil ? .white : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(viewModel.selectedStatus == nil ? Color.main : Color.gray.opacity(0.2))
                        .cornerRadius(20)

                        ForEach(OrderStatus.allValues, id: \.self) { status in
                            Button(status) {
                                viewModel.selectedStatus = status
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(viewModel.selectedStatus == status ? .white : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedStatus == status ? Color.main : Color.gray.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Order list
                    List {
                        ForEach(viewModel.filteredOrders, id: \.id) { order in
                            NavigationLink(destination: OrderDetailView(orderId: order.id)) {
                                OrderRowView(order: order) {
                                    viewModel.updateOrderStatus(orderId: order.id, status: $0)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.fetchOrders()
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
                viewModel.fetchOrders()
            }
        }
    }
}

struct OrderRowView: View {
    let order: SBOrderModel
    let onStatusUpdate: (String) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Order #\(order.id)")
                        .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                    
                    Text(order.status)
                        .font(.system(size: 14))
                        .foregroundColor(colorForStatus(order.status))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(colorForStatus(order.status).opacity(0.2))
                        .cornerRadius(8)
                }
                
                HStack(spacing: 16) {
                    Text("Items: \(order.orderItems.count)")
                    Text("Total: $\(order.totalAmount, specifier: "%.2f")")
                }
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                
                HStack {
                    Spacer()
                    Menu {
                        ForEach(OrderStatus.allValues, id: \.self) { status in
                            Button(status) {
                                onStatusUpdate(status)
                            }
                        }
                    } label: {
                        Text("Update Status")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

func colorForStatus(_ status: String) -> Color {
    switch status {
    case OrderStatus.pending.rawValue: return .gray
    case OrderStatus.inProgress.rawValue: return .orange
    case OrderStatus.complete.rawValue: return .blue
    case OrderStatus.delivered.rawValue: return .green
    case OrderStatus.cancelled.rawValue: return .red
    default: return .gray
    }
}

//#Preview {
//    SBOrderManagementView()
//}
