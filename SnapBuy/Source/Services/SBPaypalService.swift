import Foundation
import PayPal

// Configuration struct to handle sensitive data
private struct PayPalConfig {
    static var clientId: String {
        // First try to get from environment variable
        if let envClientId = ProcessInfo.processInfo.environment["PAYPAL_CLIENT_ID"] {
            return envClientId
        }
        
        // Then try to get from configuration file
        if let path = Bundle.main.path(forResource: "PayPalConfig", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let clientId = config["PayPalClientId"] as? String {
            return clientId
        }
        
        #if DEBUG
        // Only use hardcoded ID in debug builds
        return "SANDBOX_CLIENT_ID"
        #else
        fatalError("PayPal client ID not configured. Please set PAYPAL_CLIENT_ID environment variable or add PayPalConfig.plist")
        #endif
    }
    
    static var environment: Environment {
        #if DEBUG
        return .sandbox
        #else
        return .production
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
        // Initialize with secure configuration
        self.config = CoreConfig(
            clientID: PayPalConfig.clientId,
            environment: PayPalConfig.environment
        )
        
        print("PayPal initialized in \(PayPalConfig.environment) environment")
    }
}
