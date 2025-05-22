import SwiftUI

struct SBAdminOrderManagement: View {
    @State private var orders = sellerOrder.sample
    @State private var searchText = ""
    @State private var selectedStatus: OrderStatus? = nil
    @State private var showingOrderDetail: sellerOrder? = nil
    @Environment(\.dismiss) var dismiss
    
    var filteredOrders: [sellerOrder] {
        orders.filter { order in
            (selectedStatus == nil || order.status == selectedStatus!) &&
            (searchText.isEmpty ||
                order.buyer.name.localizedCaseInsensitiveContains(searchText) ||
                order.buyer.phone.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                AdminHeader(title: "Order Management", dismiss: dismiss)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by buyer or phone", text: $searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 1))
                .background(Color.white)
                .padding(.horizontal)
                
                
                
                Picker("Filter Status", selection: $selectedStatus) {
                    Text("All").tag(OrderStatus?.none)
                    ForEach(OrderStatus.allCases) { status in
                        Text(status.rawValue).tag(Optional(status))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                

                List(filteredOrders) { order in
                    Button {
                        showingOrderDetail = order
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(order.buyer.name)
                                    .font(R.font.outfitMedium.font(size: 18))
                                Text(order.buyer.address)
                                    .font(R.font.outfitRegular.font(size: 14))
                                    .foregroundColor(.gray)
                                Text(order.buyer.phone)
                                    .font(R.font.outfitRegular.font(size: 13))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text(order.status.rawValue)
                                .font(R.font.outfitMedium.font(size: 14))
                                .foregroundColor(colorForStatus(order.status))
                                .padding(6)
                                .background(colorForStatus(order.status).opacity(0.2))
                                .cornerRadius(6)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .sheet(item: $showingOrderDetail) { order in
                SBAdminOrderDetail(order: order) { updatedOrder in
                    if let index = orders.firstIndex(where: { $0.id == updatedOrder.id }) {
                        orders[index] = updatedOrder
                    }
                    showingOrderDetail = nil
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}



#Preview {
    SBAdminOrderManagement()
}
