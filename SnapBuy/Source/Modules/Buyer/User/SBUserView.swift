import SwiftUI

enum OrderTab {
    case myOrder
    case history
}

struct SBUserView: View {
    
    @State private var selectedTab: OrderTab = .myOrder
    @State private var unreviewedOrders: [SBOrderModel] = []
    @State private var buyerOrders: [SBOrderModel] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private var currentUserId: String {
        UserRepository.shared.currentUser?.id ?? ""
    }
        
    var body: some View {
        SBBaseView {
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Text(R.string.localizable.myOrder)
                        .font(R.font.outfitRegular.font(size: 16))
                        .padding(.leading,30)
                    Spacer()
                    NavigationLink(destination: SBMessageView()) {
                        Image(systemName: "ellipsis.message")
                            .padding(.trailing)
                    }
                }
                .padding()
                
                HStack {
                    TabButton(title: "My Order", tab: .myOrder, selectedTab: selectedTab) {
                        selectedTab = .myOrder
                        fetchBuyerOrders()
                    }
                    Spacer()
                    TabButton(title: "History", tab: .history, selectedTab: selectedTab) {
                        selectedTab = .history
                        fetchUnreviewedOrders()
                    }
                }
                .padding(.horizontal, 50)
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            if selectedTab == .myOrder {
                                ForEach(buyerOrders) { order in
                                    SBOrderCardView(order: order)
                                }
                            } else {
                                ForEach(unreviewedOrders) { order in
                                    UnreviewedOrderCardView(order: order)
                                }
                            }
                        }
                        .padding()
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            if selectedTab == .myOrder {
                fetchBuyerOrders()
            } else {
                fetchUnreviewedOrders()
            }
        }
    }
    
    private func fetchBuyerOrders() {
        guard !currentUserId.isEmpty else {
            errorMessage = "Please log in to view your orders"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        OrderRepository.shared.fetchBuyerOrders(buyerId: currentUserId) { result in
            isLoading = false
            switch result {
            case .success(let orders):
                buyerOrders = orders
                if orders.isEmpty {
                    errorMessage = "No orders found"
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func fetchUnreviewedOrders() {
        guard !currentUserId.isEmpty else {
            errorMessage = "Please log in to view unreviewed orders"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        OrderRepository.shared.fetchUnreviewedOrders(buyerId: currentUserId) { result in
            isLoading = false
            switch result {
            case .success(let orders):
                unreviewedOrders = orders
                if orders.isEmpty {
                    errorMessage = "No unreviewed orders found"
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct SBOrderCardView: View {
    let order: SBOrderModel
    @State private var detailedOrder: SBOrderModel?
    @State private var isLoading = true
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if isLoading {
                    ProgressView()
                        .frame(width: 60, height: 60)
                } else if let firstItem = detailedOrder?.orderItems.first {
                    AsyncImage(url: URL(string: firstItem.productImageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(firstItem.productName)
                            .font(R.font.outfitBold.font(size: 18))
                        Text("Quantity: \(firstItem.quantity)")
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text(order.status)
                        .font(R.font.outfitSemiBold.font(size: 12))
                        .foregroundColor(.blue)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    
                    Text(String(format: "$ %.2f", order.totalAmount))
                        .font(R.font.outfitSemiBold.font(size: 20))
                }
            }
            
            HStack {
                Button(action: {
                    showingDetail = true
                }) {
                    Text("Detail")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .padding()
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.5))
                        )
                }
                Button(action: {
                    
                }) {
                    Text("Tracking")
                        .frame(maxWidth: .infinity)
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .padding()
                        .background(Color.main)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width*0.8, height: 160)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2))
        )
        .sheet(isPresented: $showingDetail) {
            if let detailedOrder = detailedOrder {
                SBOrderDetailSheet(order: detailedOrder)
            }
        }
        .onAppear {
            fetchOrderDetail()
        }
    }
    
    private func fetchOrderDetail() {
        OrderRepository.shared.getOrderDetail(orderId: order.id) { result in
            isLoading = false
            switch result {
            case .success(let order):
                self.detailedOrder = order
            case .failure:
                self.detailedOrder = nil
            }
        }
    }
}

struct UnreviewedOrderCardView: View {
    @State private var navigateToReview = false
    @State private var detailedOrder: SBOrderModel?
    @State private var isLoading = true
    @State private var showingDetail = false
    let order: SBOrderModel
    
    private var hasUnreviewedItems: Bool {
        detailedOrder?.orderItems.contains(where: { !$0.isReviewed }) ?? false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if isLoading {
                    ProgressView()
                        .frame(width: 60, height: 60)
                } else if let firstItem = detailedOrder?.orderItems.first {
                    AsyncImage(url: URL(string: firstItem.productImageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(firstItem.productName)
                            .font(R.font.outfitBold.font(size: 18))
                        Text("Quantity: \(firstItem.quantity)")
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text(order.status)
                        .font(R.font.outfitSemiBold.font(size: 12))
                        .foregroundColor(.blue)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    
                    Text(String(format: "$ %.2f", order.totalAmount))
                        .font(R.font.outfitSemiBold.font(size: 20))
                }
            }
            
            HStack {
                Button(action: {
                    showingDetail = true
                }) {
                    Text("Detail")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .padding()
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.5))
                        )
                }
                if hasUnreviewedItems {
                    Button(action: {
                        navigateToReview = true
                    }) {
                        Text("Review")
                            .frame(maxWidth: .infinity)
                            .font(R.font.outfitSemiBold.font(size: 16))
                            .padding()
                            .background(Color.main)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width*0.8, height: 160)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2))
        )
        .sheet(isPresented: $showingDetail) {
            if let detailedOrder = detailedOrder {
                SBOrderDetailSheet(order: detailedOrder)
            }
        }
        .sheet(isPresented: $navigateToReview) {
            if let items = detailedOrder?.orderItems.filter({ !$0.isReviewed }) {
                NavigationView {
                    SBUnreviewedItemsView(orderItems: items)
                }
            }
        }
        .onAppear {
            fetchOrderDetail()
        }
    }
    
    private func fetchOrderDetail() {
        OrderRepository.shared.getOrderDetail(orderId: order.id) { result in
            isLoading = false
            switch result {
            case .success(let order):
                self.detailedOrder = order
            case .failure:
                self.detailedOrder = nil
            }
        }
    }
}

#Preview {
    let orderItems = [
        SBOrderItemModel(
            id: 5,
            orderId: "ORD-20250531-0001",
            productId: 2,
            productName: "Giày âu",
            productImageUrl: "abc.png",
            productNote: "Đen - XL",
            productVariantId: 2,
            quantity: 10,
            unitPrice: 10.00,
            isReviewed: false
        )
    ]
    
    let order = SBOrderModel(
        id: "ORD-20250531-0001",
        buyerId: "buyer1",
        sellerId: "seller1",
        totalAmount: 100.00,
        shippingAddress: "123 Test Street, Test City, Test Country",
        orderItems: orderItems,
        status: "Delivered"
    )
    
    return SBUserView()
}
