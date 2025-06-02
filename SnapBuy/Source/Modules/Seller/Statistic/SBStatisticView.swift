import SwiftUI
import Charts

enum TimeFilter: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct SalesData: Identifiable {
    let id = UUID()
    let label: String
    let revenue: Double
}

struct SalesStatisticsView: View {
    let allWeeklyData: [SalesData]
    let allMonthlyData: [SalesData]
    let allYearlyData: [SalesData]
    let totalOrders: Int
    let totalItemsSold: Int
    let totalRevenue: Double

    @State private var selectedFilter: TimeFilter = .month

    var filteredData: [SalesData] {
        switch selectedFilter {
        case .week:
            return allWeeklyData
        case .month:
            return allMonthlyData
        case .year:
            return allYearlyData
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Sales Overview")
                        .font(.custom("Outfit", size: 16))
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    StatsCardsView(totalOrders: totalOrders, totalItemsSold: totalItemsSold, totalRevenue: totalRevenue)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        FilterPickerView(selectedFilter: $selectedFilter)
                        
                        ChartView(filteredData: filteredData)
                    }
                    .padding()
                    
                    OrdersListView()
                }
                .padding(.top)
            }
        }
    }
}

// MARK: - Subviews

struct HeaderView: View {
    var body: some View {
        HStack {
            Spacer()
            Text("Sales Statistics")
                .font(R.font.outfitMedium.font(size: 24))
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(Color.main)
    }
}

struct StatsCardsView: View {
    let totalOrders: Int
    let totalItemsSold: Int
    let totalRevenue: Double

    var body: some View {
        HStack(spacing: 10) {
            StatCard(title: "Total Orders", value: "\(totalOrders)")
            StatCard(title: "Items Sold", value: "\(totalItemsSold)")
            StatCard(title: "Revenue", value: String(format: "$%.1f", totalRevenue))
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.custom("Outfit", size: 12))
                .foregroundColor(.secondary)
            Text(value)
                .font(.custom("Outfit", size: 20))
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FilterPickerView: View {
    @Binding var selectedFilter: TimeFilter

    var body: some View {
        HStack {
            Text("Revenue by \(selectedFilter.rawValue)")
                .font(.custom("Outfit", size: 16))
                .fontWeight(.semibold)
            Spacer()
            Picker("", selection: $selectedFilter) {
                ForEach(TimeFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
        }
        .padding(.bottom, 10)
    }
}

struct ChartView: View {
    let filteredData: [SalesData]

    var body: some View {
        Chart(filteredData) { data in
            BarMark(
                x: .value("Label", data.label),
                y: .value("Revenue", data.revenue)
            )
            .foregroundStyle(Color.main)
            .cornerRadius(6)
        }
        .frame(height: 220)
    }
}

struct OrdersListView: View {
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
//            Text("Orders")
//                .font(.custom("Outfit", size: 16))
//                .fontWeight(.semibold)
//                .padding(.horizontal)
//
//            ScrollView {
//                VStack(spacing: 10) {
//                    ForEach(sellerOrder.sample) { order in
//                        NavigationLink(destination: OrderDetailView(order: order)) {
//                            HStack {
//                                Text("Order #\(order.id.uuidString.prefix(6))")
//                                    .font(.custom("Outfit-Medium", size: 14))
//                                    .foregroundColor(.black)
//                                Spacer()
//                                Text(order.status.rawValue)
//                                    .font(.custom("Outfit-Regular", size: 12))
//                                    .foregroundColor(.gray)
//                                Text("\(order.totalQuantity) item\(order.totalQuantity > 1 ? "s" : "")")
//                                    .font(.custom("Outfit-Regular", size: 12))
//                                    .foregroundColor(.gray)
//                            }
//                            .padding()
//                            .background(Color(.systemGray6))
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                        }
//                    }
//                }
//            }
//            .frame(maxHeight: 250)
        }
    }
}
