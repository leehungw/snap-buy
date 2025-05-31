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
            endpoint: "order/api/orders/\(orderId)/status",
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
    
    static func createOrderItem(
        productId: Int,
        productName: String,
        productImageUrl: String,
        productNote: String = "",
        productVariantId: Int,
        quantity: Int,
        unitPrice: Double
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
            unitPrice: unitPrice
        )
    }
}
