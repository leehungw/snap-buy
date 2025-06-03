import SwiftUI

class SBAdminDashboardViewModel: ObservableObject {
    @Published var totalUsers: Int = 0
    @Published var totalShops: Int = 0
    @Published var totalProducts: Int = 0
    @Published var totalOrders: Int = 0
    
    func fetchDashboardData() {
        UserRepository.shared.fetchAllUsers { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.totalUsers = response.data.count ?? 0
                }
            case .failure:
                break
            }
        }
        
        // Fetch total products
        ProductRepository.shared.fetchAcceptedProducts { [weak self] result in
            switch result {
            case .success(let products):
                DispatchQueue.main.async {
                    self?.totalProducts = products.count
                }
            case .failure:
                break
            }
        }
        
        UserRepository.shared.fetchAllUsers { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.totalShops = response.data.filter { $0.isPremium}.count ?? 0
                }
            case .failure:
                break
            }
        }
        
        // Fetch total orders
        OrderRepository.shared.fetchAllOrders { [weak self] result in
            switch result {
            case .success(let orders):
                DispatchQueue.main.async {
                    self?.totalOrders = orders.count
                }
            case .failure:
                break
            }
        }
    }
}

struct SBAdminDashboardView: View {
    @StateObject private var viewModel = SBAdminDashboardViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack(alignment: .center) {
                    Text("Dashboard")
                        .font(R.font.outfitBold.font(size: 28))
                        
                    Spacer()
                    NavigationLink(destination:
                                    {SBAdminSettingsView()}) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(Color.black)
                    }
                }
                .padding(.vertical, 20)
                
                // Dashboard summary with navigation links
                NavigationLink(destination: SBAdminUserManagementView()) {
                    GridBoxView(title: "Total Users", value: "\(viewModel.totalUsers)", color: .blue, systemImage: "person.2.fill")
                }
                
                
                NavigationLink(destination: SBAdminProductManagementView()) {
                    GridBoxView(title: "Total Products", value: "\(viewModel.totalProducts)", color: .orange, systemImage: "bag.fill")
                }
                
                NavigationLink(destination: SBAdminOrderManagement()) {
                    GridBoxView(title: "Total Orders", value: "\(viewModel.totalOrders)", color: .purple, systemImage: "cart.fill")
                }
                
                NavigationLink(destination: SBAdminVoucherManagement()) {
                    GridBoxView(title: "Total Vouchers", value: "0", color: .pink, systemImage: "ticket.fill")
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.fetchDashboardData()
            }
        }
        .navigationBarHidden(true)
    }
}

struct GridBoxView: View {
    let title: String
    let value: String
    let color: Color
    let systemImage: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(R.font.outfitMedium.font(size: 16))
                    .foregroundColor(.gray)
                Text(value)
                    .font(R.font.outfitBold.font(size: 40))
                    .foregroundColor(.primary)
            }
            .padding(.leading,20)
            HStack {
                Spacer()
                HStack {
                    Image(systemName: systemImage)
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                }
                .padding(12)
                .frame(width: 70, height: 70)
                .background(color)
                .clipShape(.circle)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5))
                    .font(.system(size: 25))
                    .padding(.leading,5)
            }
            
        }
        .padding()
        .padding(.horizontal,10)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct MonthlyRevenue: Identifiable {
    let id = UUID()
    let month: String
    let revenue: Double
}

// MARK: - Placeholder Views

struct UserManagementView: View {
    var body: some View {
        Text("User Management")
            .font(R.font.outfitMedium.font(size: 20))
    }
}

struct ShopManagementView: View {
    var body: some View {
        Text("Shop Management")
            .font(R.font.outfitMedium.font(size: 20))
    }
}

struct OrderManagementView: View {
    var body: some View {
        Text("Order Management")
            .font(R.font.outfitMedium.font(size: 20))
    }
}

#Preview {
    SBAdminDashboardView()
}
