import SwiftUI

struct SBSellerDashboardView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back, Seller!")
                            .font(R.font.outfitSemiBold.font(size: 20))
                            .foregroundColor(.white)
                        Text("Here's your business overview")
                            .font(R.font.outfitRegular.font(size: 14))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {
                        print("Menu tapped")
                    }) {
                        Image(systemName: "person.crop.circle")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.main)
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 16) {
                            DashboardCard(title: "Today Revenue", value: "$240", systemImage: "dollarsign.circle")
                            DashboardCard(title: "Pending Orders", value: "5", systemImage: "clock.badge.exclamationmark")
                        }
                        HStack(spacing: 16) {
                            DashboardCard(title: "Completed", value: "23", systemImage: "checkmark.circle")
                            DashboardCard(title: "Products", value: "18", systemImage: "cube.box")
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
    }
}

struct ListRecentView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sellerOrder.sample) { order in
                    NavigationLink(destination: OrderDetailView(order: order)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Order #\(order.id.uuidString.prefix(6))")
                                    .font(.custom("Outfit-Medium", size: 14))
                                    .foregroundColor(.black)
                                Text("\(order.items.count) item\(order.items.count > 1 ? "s" : "")")
                                    .font(.custom("Outfit-Regular", size: 12))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(order.status.rawValue)
                                .font(.custom("Outfit-Medium", size: 12))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(colorForStatus(order.status).opacity(0.2))
                                .foregroundColor(colorForStatus(order.status))
                                .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.horizontal)
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
