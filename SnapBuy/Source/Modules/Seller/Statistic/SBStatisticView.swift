import SwiftUI
import Charts

enum TimeFilter: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var apiType: Int {
        switch self {
        case .week: return 1
        case .month: return 2
        case .year: return 3
        }
    }
}

struct SalesData: Identifiable, Codable {
    let id = UUID()
    let label: String
    let revenue: Double
}

struct RevenueResponse: Codable {
    let result: Int
    let data: RevenueData?
    let error: APIErrorResponse?
}

struct RevenueData: Codable {
    let totalOrder: Int
    let itemSold: Int
    let revenue: Double
}

class StatisticsViewModel: ObservableObject {
    @Published var weekData: RevenueData?
    @Published var monthData: RevenueData?
    @Published var yearData: RevenueData?
    @Published var isLoading = false
    @Published var error: String? = nil
    
    func fetchRevenue(for timeFilter: TimeFilter) {
        guard let sellerId = UserRepository.shared.currentUser?.id else {
            error = "User not found"
            return
        }
        
        isLoading = true
        error = nil
        
        let headers = ["Content-Type": "application/json"]
        print("📊 Fetching revenue for \(timeFilter.rawValue)")
        print("🔍 Debug - API URL: order/api/orders/seller/revenue/\(sellerId)/\(timeFilter.apiType)")
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/orders/seller/revenue/\(sellerId)/\(timeFilter.apiType)",
            method: "GET",
            body: nil,
            headers: headers
        ) { [weak self] (result: Result<RevenueResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if let revenueData = response.data {
                        switch timeFilter {
                        case .week:
                            self.weekData = revenueData
                        case .month:
                            self.monthData = revenueData
                        case .year:
                            self.yearData = revenueData
                        }
                    } else if let error = response.error {
                        self.error = error.message
                    }
                    
                case .failure(let error):
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    func fetchAllData() {
        TimeFilter.allCases.forEach { fetchRevenue(for: $0) }
    }
}

struct SalesStatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @State private var selectedFilter: TimeFilter = .month
    
    var currentData: RevenueData? {
        switch selectedFilter {
        case .week:
            return viewModel.weekData
        case .month:
            return viewModel.monthData
        case .year:
            return viewModel.yearData
        }
    }
    
    var chartData: [SalesData] {
        guard let data = currentData else { return [] }
        
        switch selectedFilter {
        case .week:
            return [
                SalesData(label: "Mon", revenue: data.revenue * 0.1),
                SalesData(label: "Tue", revenue: data.revenue * 0.15),
                SalesData(label: "Wed", revenue: data.revenue * 0.12),
                SalesData(label: "Thu", revenue: data.revenue * 0.18),
                SalesData(label: "Fri", revenue: data.revenue * 0.25),
                SalesData(label: "Sat", revenue: data.revenue * 0.12),
                SalesData(label: "Sun", revenue: data.revenue * 0.08)
            ]
        case .month:
            return [
                SalesData(label: "W1", revenue: data.revenue * 0.2),
                SalesData(label: "W2", revenue: data.revenue * 0.3),
                SalesData(label: "W3", revenue: data.revenue * 0.25),
                SalesData(label: "W4", revenue: data.revenue * 0.25)
            ]
        case .year:
            return [
                SalesData(label: "Q1", revenue: data.revenue * 0.2),
                SalesData(label: "Q2", revenue: data.revenue * 0.3),
                SalesData(label: "Q3", revenue: data.revenue * 0.25),
                SalesData(label: "Q4", revenue: data.revenue * 0.25)
            ]
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Text("Statistics")
                                .font(R.font.outfitBold.font(size: 28))
                                .foregroundColor(.main)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Stats Overview Cards
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 16) {
                                    StatCard(
                                        title: "Total Orders",
                                        value: "\(currentData?.totalOrder ?? 0)",
                                        icon: "cart",
                                        color: .blue
                                    )
                                    StatCard(
                                        title: "Items Sold",
                                        value: "\(currentData?.itemSold ?? 0)",
                                        icon: "cube.box",
                                        color: .purple
                                    )
                                    StatCard(
                                        title: "Revenue",
                                        value: String(format: "$%.2f", currentData?.revenue ?? 0),
                                        icon: "dollarsign.circle",
                                        color: .green
                                    )
                                    StatCard(
                                        title: "Success Rate",
                                        value: "\(calculateSuccessRate())%",
                                        icon: "chart.line.uptrend.xyaxis",
                                        color: .orange
                                    )
                                }
                                .padding(.horizontal)
                                
                                // Time Filter
                                Picker("Time Filter", selection: $selectedFilter) {
                                    ForEach(TimeFilter.allCases, id: \.self) { filter in
                                        Text(filter.rawValue)
                                            .tag(filter)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                                
                                // Revenue Chart
                                if !chartData.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("Revenue Chart")
                                                .font(R.font.outfitSemiBold.font(size: 18))
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        
                                        ChartView(data: chartData)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                    .padding(.horizontal)
                                }
                                
                                
                                if let error = viewModel.error {
                                    Text(error)
                                        .font(R.font.outfitRegular.font(size: 14))
                                        .foregroundColor(.red)
                                        .padding()
                                }
                            }
                            .padding(.vertical)
                        }
                        .refreshable {
                            viewModel.fetchAllData()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchAllData()
            }
            .onChange(of: selectedFilter) { newValue in
                viewModel.fetchRevenue(for: newValue)
            }
        }
    }
    
    private func calculateSuccessRate() -> Int {
        guard let data = currentData, data.totalOrder > 0 else { return 0 }
        return Int((Double(data.itemSold) / Double(data.totalOrder)) * 100)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Text(title)
                    .font(R.font.outfitMedium.font(size: 14))
                    .foregroundColor(.gray)
            }
            
            Text(value)
                .font(R.font.outfitBold.font(size: 24))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ChartView: View {
    let data: [SalesData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Chart(data) { item in
                BarMark(
                    x: .value("Period", item.label),
                    y: .value("Revenue", item.revenue)
                )
                .foregroundStyle(Color.main.gradient)
                .cornerRadius(8)
            }
            .frame(height: 220)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            
            // Legend
            HStack {
                Circle()
                    .fill(Color.main)
                    .frame(width: 8, height: 8)
                Text("Revenue")
                    .font(R.font.outfitRegular.font(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
}


struct OrderStatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(R.font.outfitMedium.font(size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor(status))
            .cornerRadius(12)
    }
    
    private func statusColor(_ status: String) -> Color {
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
}
