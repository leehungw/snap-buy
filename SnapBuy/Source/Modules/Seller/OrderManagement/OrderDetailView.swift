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
        isLoading = true
        error = nil
        
        OrderRepository.shared.updateOrderStatus(orderId: orderId, status: status) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
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
                        // Order Status Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                sectionTitle("Order Status")
                                Spacer()
                                Menu {
                                    ForEach(OrderStatus.allCases, id: \.self) { status in
                                        Button(status.rawValue) {
                                            viewModel.updateOrderStatus(status: status.rawValue)
                                        }
                                    }
                                } label: {
                                    Text(order.status)
                                        .font(R.font.outfitMedium.font(size: 16))
                                        .foregroundColor(colorForStatus(order.status))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(colorForStatus(order.status).opacity(0.2))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Buyer Information Section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Buyer Information")
                                .padding(.horizontal)
                            VStack(alignment: .leading, spacing: 12) {
                                buyerInfoRow(label: "ID", value: order.buyerId)
                                buyerInfoRow(label: "Address", value: order.shippingAddress, multiline: true)
                                buyerInfoRow(label: "Phone", value: order.phoneNumber)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Order Items Section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Order Items")
                                .padding(.horizontal)
                            
                            let displayedItems = showAllItems ? order.orderItems : Array(order.orderItems.prefix(2))
                            
                            ForEach(displayedItems, id: \.id) { item in
                                OrderItemRow(item: item)
                                    .padding(.horizontal)
                            }
                            
                            if order.orderItems.count > 2 {
                                Button(action: {
                                    withAnimation {
                                        showAllItems.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text(showAllItems ? "Show Less" : "Show More")
                                            .font(R.font.outfitMedium.font(size: 16))
                                        Image(systemName: showAllItems ? "chevron.up" : "chevron.down")
                                    }
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Summary Section
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Summary")
                                .padding(.horizontal)
                            VStack(spacing: 12) {
                                HStack {
                                    Label("Total Items", systemImage: "cart")
                                        .font(R.font.outfitMedium.font(size: 16))
                                    Spacer()
                                    Text("\(order.orderItems.count)")
                                        .font(R.font.outfitBold.font(size: 20))
                                }
                                
                                Divider()
                                
                                HStack {
                                    Label("Total Amount", systemImage: "dollarsign.circle")
                                        .font(R.font.outfitMedium.font(size: 16))
                                    Spacer()
                                    Text(String(format: "$%.2f", order.totalAmount))
                                        .font(R.font.outfitBold.font(size: 20))
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
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
                .font(R.font.outfitMedium.font(size: 16))
            Spacer()
            Text(value)
                .font(R.font.outfitRegular.font(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
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
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .lineLimit(2)

                    VStack(spacing: 8) {
                        if !item.productNote.isEmpty {
                            itemInfoRow(label: "Note", value: item.productNote)
                        }
                        itemInfoRow(label: "Quantity", value: "\(item.quantity)")
                        itemInfoRow(label: "Price", value: String(format: "$%.2f", item.unitPrice))

                        Divider()

                        HStack {
                            Text("Subtotal")
                                .font(R.font.outfitMedium.font(size: 16))
                            Spacer()
                            Text(String(format: "$%.2f", item.unitPrice * Double(item.quantity)))
                                .font(R.font.outfitBold.font(size: 16))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func itemInfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(R.font.outfitRegular.font(size: 14))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(R.font.outfitMedium.font(size: 14))
        }
    }
}

#Preview {
    OrderDetailView(orderId: "1")
}
