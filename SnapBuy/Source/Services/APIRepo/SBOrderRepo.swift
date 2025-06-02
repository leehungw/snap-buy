import Foundation

final class OrderRepository {
    static let shared = OrderRepository()
    private init() {}
    
    // MARK: - Create Order
    func createOrder(
        buyerId: String,
        sellerId: String,
        totalAmount: Double,
        shippingAddress: String,
        items: [SBOrderItemModel],
        status: String,
        completion: @escaping SBValueAction<Result<SBOrderModel, Error>>
    ) {
        print("📦 Creating new order for buyer: \(buyerId), seller: \(sellerId)")
        
        let order = SBOrderModel(
            id: "string",
            buyerId: buyerId,
            sellerId: sellerId,
            totalAmount: totalAmount,
            shippingAddress: shippingAddress,
            orderItems: items.map { item in
                var newItem = item
                newItem.id = 0
                newItem.orderId = "string"
                return newItem
            },
            status: status
        )
        
        guard let jsonData = try? JSONEncoder().encode(order) else {
            let encodingError = NSError(
                domain: "OrderRepository",
                code: -1001,
                userInfo: [NSLocalizedDescriptionKey: "Unable to encode order request"]
            )
            completion(.failure(encodingError))
            return
        }
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/orders",
            method: "POST",
            body: jsonData,
            headers: headers
        ) { (result: Result<OrderResponse, Error>) in
            switch result {
            case .success(let response):
                print("✅ Order creation response received: \(response)")
                if let order = response.data {
                    completion(.success(order))
                } else if let error = response.error {
                    let apiError = NSError(
                        domain: "OrderRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to create order"]
                    )
                    completion(.failure(apiError))
                } else {
                    let error = NSError(
                        domain: "OrderRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to create order"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Orders by Status
    func fetchOrdersByStatus(status: String, completion: @escaping SBValueAction<Result<[SBOrderModel], Error>>) {
        print("📦 Fetching orders with status: \(status)")
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/orders/status/\(status)",
            method: "GET",
            body: nil,
            headers: headers
        ) { (result: Result<OrderListResponse, Error>) in
            switch result {
            case .success(let response):
                if let orders = response.data {
                    print("✅ Successfully fetched \(orders.count) orders with status: \(status)")
                    completion(.success(orders))
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "OrderRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to fetch orders"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ No orders found")
                    let error = NSError(
                        domain: "OrderRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No orders found"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Seller Orders
    func fetchListSellerOrders(sellerId: String, completion: @escaping SBValueAction<Result<[SBOrderModel], Error>>) {
        print("📦 Fetching orders for seller: \(sellerId)")
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/orders/seller/\(sellerId)",
            method: "GET",
            body: nil,
            headers: headers
        ) { (result: Result<OrderListResponse, Error>) in
            switch result {
            case .success(let response):
                print("📦 API Response: \(response)")
                if let orders = response.data {
                    print("✅ Successfully fetched \(orders.count) orders for seller")
                    completion(.success(orders))
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "OrderRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to fetch orders"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ No orders found")
                    let error = NSError(
                        domain: "OrderRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No orders found"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get Order Detail
    func getOrderDetail(orderId: String, completion: @escaping SBValueAction<Result<SBOrderModel, Error>>) {
        print("📦 Fetching order detail for ID: \(orderId)")
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/orders/\(orderId)",
            method: "GET",
            body: nil,
            headers: headers
        ) { (result: Result<OrderResponse, Error>) in
            switch result {
            case .success(let response):
                print("✅ Order detail response received: \(response)")
                
                if let order = response.data {
                    print("📦 Successfully parsed order")
                    completion(.success(order))
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "OrderRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to fetch order"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ Order not found")
                    let error = NSError(
                        domain: "OrderRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Order not found"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Update Order Status
    func updateOrderStatus(orderId: String, status: String, completion: @escaping SBValueAction<Result<SBOrderModel, Error>>) {
        print("📦 Updating order \(orderId) status to: \(status)")
        
        let request = ["status": status]
        
        guard let jsonData = try? JSONEncoder().encode(request) else {
            let error = NSError(
                domain: "OrderRepository",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode status update request"]
            )
            completion(.failure(error))
            return
        }
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/orders/\(orderId)/\(status)",
            method: "PUT",
            body: jsonData,
            headers: headers
        ) { (result: Result<OrderResponse, Error>) in
            switch result {
            case .success(let response):
                print("✅ Status update response received: \(response)")
                
                if let order = response.data {
                    print("📦 Successfully updated order status")
                    completion(.success(order))
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "OrderRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to update status"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ Failed to update status")
                    let error = NSError(
                        domain: "OrderRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to update order status"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Unreviewed Orders
    func fetchUnreviewedOrders(buyerId: String, completion: @escaping SBValueAction<Result<[SBOrderModel], Error>>) {
        print("📦 Fetching unreviewed orders for buyer: \(buyerId)")
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/orders/orderItems/unReviewed/\(buyerId)",
            method: "GET",
            body: nil,
            headers: headers
        ) { (result: Result<OrderItemsResponse, Error>) in
            switch result {
            case .success(let response):
                if let orderItems = response.data {
                    print("✅ Successfully fetched \(orderItems.count) unreviewed order items")
                    
                    // Group order items by orderId
                    let groupedItems = Dictionary(grouping: orderItems, by: { $0.orderId })
                    let orderIds = Array(groupedItems.keys)
                    
                    // Create a dispatch group to wait for all order details
                    let group = DispatchGroup()
                    var orders: [SBOrderModel] = []
                    var errors: [Error] = []
                    
                    // Fetch complete order details for each orderId
                    for orderId in orderIds {
                        group.enter()
                        self.getOrderDetail(orderId: orderId) { result in
                            switch result {
                            case .success(var order):
                                // Replace order items with unreviewed items
                                if let items = groupedItems[orderId] {
                                    order.orderItems = items
                                }
                                orders.append(order)
                            case .failure(let error):
                                errors.append(error)
                            }
                            group.leave()
                        }
                    }
                    
                    // When all orders are fetched
                    group.notify(queue: .main) {
                        if !errors.isEmpty {
                            // If there were any errors, return the first one
                            completion(.failure(errors[0]))
                        } else {
                            completion(.success(orders))
                        }
                    }
                    
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "OrderRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to fetch unreviewed orders"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ No unreviewed orders found")
                    let error = NSError(
                        domain: "OrderRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No unreviewed orders found"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Buyer Orders
    func fetchBuyerOrders(buyerId: String, completion: @escaping SBValueAction<Result<[SBOrderModel], Error>>) {
        print("📦 Fetching orders for buyer: \(buyerId)")
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/orders/buyer/\(buyerId)",
            method: "GET",
            body: nil,
            headers: headers
        ) { (result: Result<OrderListResponse, Error>) in
            switch result {
            case .success(let response):
                if let orders = response.data {
                    print("✅ Successfully fetched \(orders.count) orders for buyer")
                    completion(.success(orders))
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "OrderRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to fetch buyer orders"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ No orders found")
                    let error = NSError(
                        domain: "OrderRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No orders found"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch All Orders
    func fetchAllOrders(completion: @escaping SBValueAction<Result<[SBOrderModel], Error>>) {
        print("📦 Fetching all orders")
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/orders",
            method: "GET",
            body: nil,
            headers: headers
        ) { (result: Result<OrderListResponse, Error>) in
            switch result {
            case .success(let response):
                if let orders = response.data {
                    print("✅ Successfully fetched \(orders.count) orders")
                    
                    // Create a dispatch group to wait for all order details
                    let group = DispatchGroup()
                    var detailedOrders: [SBOrderModel] = []
                    var errors: [Error] = []
                    
                    // Fetch complete order details for each order
                    for order in orders {
                        group.enter()
                        self.getOrderDetail(orderId: order.id) { detailResult in
                            switch detailResult {
                            case .success(let detailedOrder):
                                detailedOrders.append(detailedOrder)
                            case .failure(let error):
                                errors.append(error)
                            }
                            group.leave()
                        }
                    }
                    
                    // When all order details are fetched
                    group.notify(queue: .main) {
                        if !errors.isEmpty {
                            // If there were any errors, return the first one
                            completion(.failure(errors[0]))
                        } else {
                            completion(.success(detailedOrders))
                        }
                    }
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "OrderRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to fetch orders"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ No orders found")
                    let error = NSError(
                        domain: "OrderRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No orders found"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    static func createOrderItem(
        productId: Int,
        productName: String,
        productImageUrl: String,
        productNote: String = "",
        productVariantId: Int,
        quantity: Int,
        unitPrice: Double,
        isReviewed: Bool
    ) -> SBOrderItemModel {
        return SBOrderItemModel(
            id: 0,
            orderId: "string",
            productId: productId,
            productName: productName,
            productImageUrl: productImageUrl,
            productNote: productNote,
            productVariantId: productVariantId,
            quantity: quantity,
            unitPrice: unitPrice,
            isReviewed: isReviewed
        )
    }
    
    func updateOrderItemReviewStatus(orderItemId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        print("📝 Updating review status for order item: \(orderItemId)")
        
        let headers = ["Content-Type": "application/json"]
        
        struct UpdateResponse: Codable {
            let result: Int
            let data: Int
            let error: APIErrorResponse?
        }
        
        SBAPIService.shared.performRequest(
            endpoint: "order/api/orders/orderItems/\(orderItemId)",
            method: "PUT",
            body: nil,
            headers: headers
        ) { (result: Result<UpdateResponse, Error>) in
            switch result {
            case .success(let response):
                if response.result > 0 {
                    print("✅ Successfully updated order item review status")
                    completion(.success(()))
                } else if let error = response.error {
                    print("❌ API Error: \(error)")
                    let apiError = NSError(
                        domain: "OrderRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to update review status"]
                    )
                    completion(.failure(apiError))
                } else {
                    print("❌ Failed to update review status")
                    let error = NSError(
                        domain: "OrderRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to update review status"]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ Failed to update order item review status: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
