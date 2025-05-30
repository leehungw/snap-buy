import SwiftUI

class OrderDetailViewModel: ObservableObject {
    @Published var order: SBOrderModel?
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchOrderDetail(orderId: String) {
        isLoading = true
        error = nil
        
        OrderRepository.shared.getOrderDetail(orderId: orderId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let order):
                    self?.order = order
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func updateOrderStatus(status: String) {
        guard let orderId = order?.id else { return }
        
        OrderRepository.shared.updateOrderStatus(orderId: orderId, status: status) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedOrder):
                    self?.order = updatedOrder
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}

struct OrderDetailView: View {
    let orderId: String
    @StateObject private var viewModel = OrderDetailViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showAllItems = false
    @State private var showErrorAlert = false

    var body: some View {
        VStack {
            Header(title: "Order #\(orderId)", dismiss: dismiss)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let order = viewModel.order {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Buyer Information Section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Buyer Information")
                                .padding(.horizontal)
                            VStack(alignment: .leading, spacing: 12) {
                                buyerInfoRow(label: "Name", value: order.buyerId)
                                buyerInfoRow(label: "Address", value: order.shippingAddress, multiline: true)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        // Order Items Section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Order Items")
                            
                            let displayedItems = showAllItems ? order.orderItems : Array(order.orderItems.prefix(2))
                            
                            ForEach(displayedItems, id: \.id) { item in
                                OrderItemRow(item: item)
                            }
                            
                            if order.orderItems.count > 2 {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        withAnimation {
                                            showAllItems.toggle()
                                        }
                                    }) {
                                        Text(showAllItems ? "Show Less" : "Show More")
                                            .font(.custom("Outfit", size: 16))
                                            .fontWeight(.medium)
                                            .foregroundColor(.blue)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Summary Section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Summary")
                                .padding(.horizontal)
                            VStack {
                                HStack {
                                    Text("Total Items")
                                        .font(.custom("Outfit", size: 16))
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("\(order.orderItems.count)")
                                        .font(.custom("Outfit", size: 20))
                                        .fontWeight(.bold)
                                }
                                HStack {
                                    Text("Total Amount")
                                        .font(.custom("Outfit", size: 16))
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text(String(format: "$%.2f", order.totalAmount))
                                        .font(.custom("Outfit", size: 20))
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        // Order Status Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                sectionTitle("Order Status")
                                Spacer()
                                Menu {
                                    ForEach(OrderStatus.allValues, id: \.self) { status in
                                        Button(status) {
                                            viewModel.updateOrderStatus(status: status)
                                        }
                                    }
                                } label: {
                                    Text(order.status)
                                        .font(.custom("Outfit", size: 16))
                                        .foregroundColor(colorForStatus(order.status))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(colorForStatus(order.status).opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.error ?? "Unknown error occurred")
        }
        .onChange(of: viewModel.error) { newValue in
            showErrorAlert = newValue != nil
        }
        .onAppear {
            viewModel.fetchOrderDetail(orderId: orderId)
        }
    }

    // MARK: - Helper Views
    @ViewBuilder
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(R.font.outfitBold.font(size: 18))
    }

    private func buyerInfoRow(label: String, value: String, multiline: Bool = false) -> some View {
        HStack(alignment: multiline ? .top : .center) {
            Text(label)
                .font(.custom("Outfit", size: 16))
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
                .font(.custom("Outfit", size: 16))
        }
    }
}

struct OrderItemRow: View {
    let item: SBOrderItemModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                AsyncImage(url: URL(string: item.productImageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 100, height: 100)
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 10) {
                    Text(item.productName)
                        .font(.custom("Outfit", size: 18))
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        if !item.productNote.isEmpty {
                            itemInfoRow(label: "Note", value: item.productNote)
                        }
                        itemInfoRow(label: "Quantity", value: "\(item.quantity)")
                        itemInfoRow(label: "Price per item", value: String(format: "$%.2f", item.unitPrice))

                        Divider()

                        HStack {
                            Text("Subtotal")
                                .font(.custom("Outfit", size: 16))
                                .fontWeight(.semibold)
                            Spacer()
                            Text(String(format: "$%.2f", item.unitPrice * Double(item.quantity)))
                                .font(.custom("Outfit", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    private func itemInfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.custom("Outfit", size: 16))
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .font(.custom("Outfit", size: 16))
        }
    }
}

#Preview {
    OrderDetailView(orderId: "1")
}
