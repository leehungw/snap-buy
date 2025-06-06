import SwiftUI

struct DashboardStats {
    var todayRevenue: Double = 0
    var pendingOrders: Int = 0
    var completedOrders: Int = 0
    var approvedProducts: Int = 0
}

struct SBSellerDashboardView: View {
    @StateObject private var userModeManager = UserModeManager.shared
    @State private var showSellerProfile = false
    @State private var stats = DashboardStats()
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let user = UserRepository.shared.currentUser {
                            Text("Welcome back, \(user.name)!")
                                .font(R.font.outfitSemiBold.font(size: 20))
                                .foregroundColor(.white)
                        } else {
                        Text("Welcome back, Seller!")
                            .font(R.font.outfitSemiBold.font(size: 20))
                            .foregroundColor(.white)
                        }
                        Text("Here's your business overview")
                            .font(R.font.outfitRegular.font(size: 14))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {
                        showSellerProfile = true
                    }) {
                        ZStack {
                        Image(systemName: "person.crop.circle")
                            .font(.title)
                            .foregroundColor(.white)
                            
                            // Show a red dot indicator if PayPal is not connected
                            if userModeManager.paypalOnboardingURL != nil {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.main)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            loadDashboardData()
                        }
                        .padding()
                        .background(Color.main)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                    Spacer()
                } else {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 16) {
                                DashboardCard(
                                    title: "Today Revenue",
                                    value: formatCurrency(stats.todayRevenue),
                                    systemImage: "dollarsign.circle"
                                )
                                DashboardCard(
                                    title: "Pending Orders",
                                    value: "\(stats.pendingOrders)",
                                    systemImage: "clock.badge.exclamationmark"
                                )
                        }
                        HStack(spacing: 16) {
                                DashboardCard(
                                    title: "Completed",
                                    value: "\(stats.completedOrders)",
                                    systemImage: "checkmark.circle"
                                )
                                DashboardCard(
                                    title: "Products",
                                    value: "\(stats.approvedProducts)",
                                    systemImage: "cube.box"
                                )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    Text("Recent Orders")
                        .font(R.font.outfitBold.font(size: 18))
                        .padding(.horizontal)
                    ListRecentView()
                    }
                }
            }
            .onAppear {
                loadDashboardData()
            }
            .refreshable {
                loadDashboardData()
            }
            .sheet(isPresented: $showSellerProfile) {
                SBSellerProfileView()
            }
        }
    }
    
    private func loadDashboardData() {
        guard let sellerId = UserRepository.shared.currentUser?.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        let group = DispatchGroup()
        var tempStats = DashboardStats()
        var loadError: Error?
        
        // Fetch approved products count
        group.enter()
        ProductRepository.shared.fetchAllProductsBySellerId(sellerId: sellerId) { result in
            switch result {
            case .success(let products):
                tempStats.approvedProducts = products.filter { $0.status == ProductStatus.approved.rawValue }.count
            case .failure(let error):
                loadError = error
            }
            group.leave()
        }
        
        // Fetch pending orders
        group.enter()
        fetchPendingOrders()
        group.leave()
        
        // Fetch completed orders and calculate revenue
        group.enter()
        calculateSuccessRate()
        group.leave()
        
        group.notify(queue: .main) {
            isLoading = false
            if let error = loadError {
                errorMessage = error.localizedDescription
            } else {
                stats = tempStats
            }
        }
    }
    
    private func fetchPendingOrders() {
        guard let sellerId = UserRepository.shared.currentUser?.id else { return }
        
        OrderRepository.shared.fetchOrdersByStatus(status: OrderStatus.pending.rawValue) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let orders):
                    self.stats.pendingOrders = orders.filter { $0.sellerId == sellerId }.count
                case .failure(let error):
                    print("Error fetching pending orders: \(error)")
                }
            }
        }
    }
    
    private func calculateSuccessRate() {
        guard let sellerId = UserRepository.shared.currentUser?.id else { return }
        
        OrderRepository.shared.fetchAllOrders { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let orders):
                    let sellerOrders = orders.filter { $0.sellerId == sellerId }
                    let successOrders = sellerOrders.filter { $0.status == OrderStatus.success.rawValue }
                    self.stats.completedOrders = successOrders.count
                    self.stats.todayRevenue = successOrders.reduce(0) { $0 + $1.totalAmount }
                case .failure(let error):
                    print("Error calculating success rate: \(error)")
                }
            }
        }
    }
}

struct ListRecentView: View {
    @State private var recentOrders: [SBOrderModel] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if recentOrders.isEmpty {
                Text("No recent orders")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(recentOrders) { order in
                        OrderItemView(order: order)
                    }
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            loadRecentOrders()
        }
    }
    
    private func loadRecentOrders() {
        guard let sellerId = UserRepository.shared.currentUser?.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        OrderRepository.shared.fetchListSellerOrders(sellerId: sellerId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let orders):
                    let sortedOrders = orders.sorted { $0.id > $1.id }
                    if sortedOrders.count > 3 {
                        self.recentOrders = Array(sortedOrders[0...2])
                    } else {
                        self.recentOrders = sortedOrders
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct OrderItemView: View {
    let order: SBOrderModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Order #\(order.id)")
                    .font(R.font.outfitMedium.font(size: 16))
                Text(order.shippingAddress)
                    .font(R.font.outfitRegular.font(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", order.totalAmount))")
                    .font(R.font.outfitBold.font(size: 16))
                Text(order.status.capitalized)
                    .font(R.font.outfitRegular.font(size: 14))
                    .foregroundColor(getStatusColor(order.status))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(getStatusColor(order.status).opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func getStatusColor(_ status: String) -> Color {
        if let orderStatus = OrderStatus.fromString(status) {
            return orderStatus.color
        }
        return .gray
    }
}

struct DashboardCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(R.font.outfitRegular.font(size: 14))
                    .foregroundColor(.gray)
                
                HStack {
                    Text(value)
                        .font(R.font.outfitBold.font(size: 22))
                    Spacer()
                    Image(systemName: systemImage)
                        .font(.title)
                        .foregroundColor(.main)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    SBSellerDashboardView()
}
