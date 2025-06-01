import Foundation
import PayPal

// Configuration struct to handle sensitive data
private struct PayPalConfig {
    static var clientId: String {
        if let path = Bundle.main.path(forResource: "PayPalConfig", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let clientId = config["PayPalClientId"] as? String {
            return clientId
        }
        
        #if DEBUG
        // Only use hardcoded ID in debug builds
        return "YOUR_CLIENT_ID" // Replace with your sandbox client ID
        #else
        fatalError("PayPal client ID not configured. Please add PayPalConfig.plist")
        #endif
    }
    
    static var secret: String {
        if let path = Bundle.main.path(forResource: "PayPalConfig", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let secret = config["Secret"] as? String {
            return secret
        }
        
        #if DEBUG
        // Only use hardcoded ID in debug builds
        return "YOUR_SECRET" // Replace with your sandbox secret
        #else
        fatalError("PayPal secret not configured. Please add PayPalConfig.plist")
        #endif
    }
}

class SBPaypalService {
    static let shared = SBPaypalService()
    
    private let config: CoreConfig
    lazy var payPalClient: PayPalWebCheckoutClient = {
        return PayPalWebCheckoutClient(config: config)
    }()
    
    private init() {
        self.config = CoreConfig(
            clientID: PayPalConfig.clientId,
            environment: .sandbox // Use .production for release
        )
        
        print("PayPal initialized in sandbox environment")
    }
    
    private func getAccessToken() async throws -> String {
        let url = URL(string: "https://api-m.sandbox.paypal.com/v1/oauth2/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Create basic auth header with client ID and secret
        let credentials = "\(PayPalConfig.clientId):\(PayPalConfig.secret)"
        if let credentialsData = credentials.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
        
        // Add grant_type to body
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "PayPal", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get access token"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let accessToken = json["access_token"] as? String else {
            throw NSError(domain: "PayPal", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid token response"])
        }
        
        return accessToken
    }
    
    private func convertVNDtoUSD(_ amountVND: Double) -> Double {
        // Using a fixed conversion rate of 1 USD = ~24,500 VND
        // In a production app, you should use a real-time exchange rate API
        let conversionRate: Double = 24500
        let amountUSD = amountVND / conversionRate
        // Round to 2 decimal places
        return (amountUSD * 100).rounded() / 100
    }
    
    func createOrder(amount: Double) async throws -> String {
        // First get the access token
        let accessToken = try await getAccessToken()
        
        // Convert amount from VND to USD
        let amountUSD = convertVNDtoUSD(amount)
        
        // PayPal Orders v2 API endpoint
        let url = URL(string: "https://api-m.sandbox.paypal.com/v2/checkout/orders")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Set up the order request body
        let orderRequest: [String: Any] = [
            "intent": "CAPTURE",
            "purchase_units": [
                [
                    "amount": [
                        "currency_code": "USD",
                        "value": String(format: "%.2f", amountUSD)
                    ]
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: orderRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw NSError(domain: "PayPal", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create PayPal order"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let orderId = json["id"] as? String else {
            throw NSError(domain: "PayPal", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid PayPal response"])
        }
        
        return orderId
    }
}
