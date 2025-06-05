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
        isLoading = true
        error = nil
        
        OrderRepository.shared.updateOrderStatus(orderId: orderId, status: status) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let updatedOrder):
                    // Update the order in the local array
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
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Text("Orders")
                                .font(R.font.outfitBold.font(size: 28))
                                .foregroundColor(.main)
                            Spacer()
                        }
                        
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search orders...", text: $searchText)
                                .font(R.font.outfitRegular.font(size: 16))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .padding()
                    .background(Color.white)
                    
                    // Filter buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterButton(
                                title: "All",
                                isSelected: viewModel.selectedStatus == nil,
                                action: { viewModel.selectedStatus = nil }
                            )
                            
                            ForEach(OrderStatus.allValues, id: \.self) { status in
                                FilterButton(
                                    title: status,
                                    isSelected: viewModel.selectedStatus == status,
                                    color: colorForStatus(status),
                                    action: { viewModel.selectedStatus = status }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color.white)
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Spacer()
                    } else if viewModel.filteredOrders.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No orders found")
                                .font(R.font.outfitMedium.font(size: 18))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredOrders.filter {
                                    searchText.isEmpty ||
                                    $0.id.localizedCaseInsensitiveContains(searchText)
                                }, id: \.id) { order in
                                    NavigationLink(destination: OrderDetailView(orderId: order.id)) {
                                        OrderRowView(order: order) { status in
                                            viewModel.updateOrderStatus(orderId: order.id, status: status)
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            viewModel.fetchOrders()
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
                viewModel.fetchOrders()
            }
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    var color: Color = .main
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(R.font.outfitMedium.font(size: 14))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color : Color.gray.opacity(0.1))
                )
        }
    }
}

struct OrderRowView: View {
    let order: SBOrderModel
    let onStatusUpdate: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Order header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.id)
                        .font(R.font.outfitBold.font(size: 16))
                    Text(formatDate(from: order.id))
                        .font(R.font.outfitRegular.font(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Menu {
                    ForEach(OrderStatus.allValues, id: \.self) { status in
                        Button(status) {
                            onStatusUpdate(status)
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
            
            Divider()
            
            // Order details
            VStack(spacing: 12) {
                HStack {
                    Label(
                        title: { Text("\(order.orderItems.count) items") },
                        icon: { Image(systemName: "cart").foregroundColor(.gray) }
                    )
                    .font(R.font.outfitMedium.font(size: 14))
                    
                    Spacer()
                    
                   
                }
                
                if !order.shippingAddress.isEmpty {
                    HStack(alignment: .bottom) {
                        Image(systemName: "location")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        
                        Text(order.shippingAddress)
                            .font(R.font.outfitRegular.font(size: 14))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                        
                        Spacer()
                        Text(String(format: "$%.2f", order.totalAmount))
                            .font(R.font.outfitBold.font(size:20))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatDate(from orderId: String) -> String {
        return "Today" // Placeholder
    }
}

func colorForStatus(_ status: String) -> Color {
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

#Preview {
    SBOrderManagementView()
}
