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
        return "YOUR_PLATFORM_CLIENT_ID" // Replace with your sandbox platform client ID
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
        return "YOUR_PLATFORM_SECRET"
        #else
        fatalError("PayPal secret not configured. Please add PayPalConfig.plist")
        #endif
    }
    
    // Partner ID for the platform
    static var partnerId: String {
        if let path = Bundle.main.path(forResource: "PayPalConfig", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let partnerId = config["PartnerId"] as? String {
            return partnerId
        }
        
        #if DEBUG
        return "YOUR_PARTNER_ID"
        #else
        fatalError("PayPal partner ID not configured. Please add PayPalConfig.plist")
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
            environment: .sandbox
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
        return 10
    }
    
    // MARK: - Seller Management
    
    /// Create a connected seller account (merchant onboarding)
    func onboardSeller(sellerId: String, email: String, businessName: String) async throws -> String {
        let accessToken = try await getAccessToken()
        
        let url = URL(string: "https://api-m.sandbox.paypal.com/v2/customer/partner-referrals")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let referralData: [String: Any] = [
            "operations": [[
                "operation": "API_INTEGRATION",
                "api_integration_preference": [
                    "rest_api_integration": [
                        "integration_method": "PAYPAL",
                        "integration_type": "THIRD_PARTY",
                        "third_party_details": [
                            "features": [
                                "PAYMENT",
                                "REFUND",
                                "PARTNER_FEE"
                            ]
                        ]
                    ]
                ]
            ]],
            "products": ["EXPRESS_CHECKOUT"],
            "legal_consents": [[
                "type": "SHARE_DATA_CONSENT",
                "granted": true
            ]],
            "business_entity": [
                "business_type": [
                    "type": "INDIVIDUAL"
                ],
                "business_name": businessName,
                "email": email,
                "addresses": [[
                    "country_code": "US"
                ]]
            ],
            "partner_config_override": [
                "return_url": "snapbuy://return",
                "return_url_description": "Return to SnapBuy app"
            ],
            "preferred_language_code": "en-US",
            "tracking_id": UUID().uuidString
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: referralData)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug logging
        if let requestBody = String(data: jsonData, encoding: .utf8) {
            print("Debug - PayPal Request Body: \(requestBody)")
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("Debug - PayPal Response: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "PayPalError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create partner referral"])
        }
        
        let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let links = responseDict?["links"] as? [[String: Any]],
              let actionUrl = links.first(where: { ($0["rel"] as? String) == "action_url" })?["href"] as? String else {
            throw NSError(domain: "PayPalError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing action URL in response"])
        }
        
        return actionUrl
    }
    
    // MARK: - Order Management
    
    /// Create a platform order with connected seller
    func createPlatformOrder(amount: Double, sellerId: String, sellerPaypalMerchantId: String) async throws -> String {
        let accessToken = try await getAccessToken()
        let amountUSD = convertVNDtoUSD(amount)
        
        // Platform fee (e.g., 10%)
        let platformFee = (amountUSD * 0.1 * 100).rounded() / 100
        let sellerAmount = ((amountUSD - platformFee) * 100).rounded() / 100
        
        let url = URL(string: "https://api-m.sandbox.paypal.com/v2/checkout/orders")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let orderRequest: [String: Any] = [
            "intent": "CAPTURE",
            "purchase_units": [[
                "reference_id": sellerId,
                "payee": [
                    "merchant_id": sellerPaypalMerchantId
                ],
                "payment_instruction": [
                    "platform_fees": [[
                        "amount": [
                            "currency_code": "USD",
                            "value": String(format: "%.2f", platformFee)
                        ]
                    ]]
                ],
                "amount": [
                    "currency_code": "USD",
                    "value": String(format: "%.2f", amountUSD),
                    "breakdown": [
                        "item_total": [
                            "currency_code": "USD",
                            "value": String(format: "%.2f", amountUSD)
                        ],
                        "platform_fees": [
                            "currency_code": "USD",
                            "value": String(format: "%.2f", platformFee)
                        ]
                    ]
                ]
            ]]
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
    
    /// Capture a platform order after buyer approval
    func captureOrder(orderId: String) async throws {
        let accessToken = try await getAccessToken()
        
        let url = URL(string: "https://api-m.sandbox.paypal.com/v2/checkout/orders/\(orderId)/capture")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw NSError(domain: "PayPal", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to capture PayPal order"])
        }
    }
}
