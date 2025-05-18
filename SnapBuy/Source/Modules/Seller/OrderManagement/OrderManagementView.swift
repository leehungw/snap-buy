import SwiftUI

struct SBOrderManagementView: View {
    @State private var orders: [sellerOrder] = sellerOrder.sample
    @State private var selectedStatus: OrderStatus? = nil

    var filteredOrders: [sellerOrder] {
        if let status = selectedStatus {
            return orders.filter { $0.status == status }
        }
        return orders
    }

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
                            selectedStatus = nil
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedStatus == nil ? .white : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedStatus == nil ? Color.main : Color.gray.opacity(0.2))
                        .cornerRadius(20)

                        ForEach(OrderStatus.allCases) { status in
                            Button(status.rawValue) {
                                selectedStatus = status
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedStatus == status ? .white : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedStatus == status ? Color.main : Color.gray.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)

                // Order list
                List {
                    ForEach(filteredOrders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            HStack(alignment: .top, spacing: 16) {
                                // Ảnh sản phẩm đầu tiên
                                if let firstItem = order.items.first {
                                    Image(firstItem.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                        .clipped()
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        
                                        Text(order.orderTitle)
                                            .font(.system(size: 16, weight: .medium))
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)

                                        Spacer()

                                        // Trạng thái
                                        Text(order.status.rawValue)
                                            .font(.system(size: 14))
                                            .foregroundColor(colorForStatus(order.status))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(colorForStatus(order.status).opacity(0.2))
                                            .cornerRadius(8)
                                    }

                                    // Tổng số lượng và tổng tiền
                                    HStack(spacing: 16) {
                                        Text("Quantity: \(order.totalQuantity)")
                                        Text("Total: $\(order.totalAmount, specifier: "%.2f")")
                                    }
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)

                                    // Nút cập nhật trạng thái
                                    HStack {
                                        Spacer()
                                        Menu {
                                            ForEach(OrderStatus.allCases) { status in
                                                Button(status.rawValue) {
                                                    updateStatus(of: order, to: status)
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
                }
                .listStyle(.plain)
            }
            .navigationBarHidden(true)
        }
    }

    private func updateStatus(of order: sellerOrder, to newStatus: OrderStatus) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index].status = newStatus
        }
    }
}

extension sellerOrder {
    var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var totalAmount: Double {
        items.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }

    var orderTitle: String {
        items.map { $0.title }.joined(separator: ", ")
    }
}

#Preview {
    SBOrderManagementView()
}
func colorForStatus(_ status: OrderStatus) -> Color {
    switch status {
    case .pending: return .gray
    case .inProgress: return .orange
    case .complete: return .blue
    case .delivered: return .green
    case .cancelled: return .red
    }
}
