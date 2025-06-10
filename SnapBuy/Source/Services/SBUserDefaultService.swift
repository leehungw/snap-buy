import Foundation
import Combine

struct SBCartStorageItem: Codable {
    let productId: Int
    let variantId: Int
    let quantity: Int
}

class SBUserDefaultService {
    static let instance = SBUserDefaultService()
    private var cancellables = Set<AnyCancellable>()
    
    @UserDefaultWrapper("did_show_onboarding", defaultValue: false)
    var didShowOnboarding: Bool
    
    @UserDefaultWrapper("cart_items", defaultValue: [])
    var cartItems: [SBCartStorageItem]
    
    private init() {
    }
    
    func addToCart(productId: Int, variantId: Int, quantity: Int) {
        var currentItems = cartItems
        currentItems.append(SBCartStorageItem(productId: productId, variantId: variantId, quantity: quantity))
        cartItems = currentItems
    }
    
    func clearCart() {
        cartItems = []
    }
}

@propertyWrapper
public struct UserDefaultWrapper<T: Codable> {
    let defaultValue: T
    let key: String
    
    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            if let value = UserDefaults.standard.get(T.self, key: key) {
                return value
            } else {
                return defaultValue
            }
        }
        set {
            UserDefaults.standard.set(T.self, value: newValue, key: key)
        }
    }
}

public extension UserDefaults {
    func get<T: Codable>(_ type: T.Type, key: String) -> T? {
        guard let valueAsString = string(forKey: key) else {
            return nil
        }
        guard let valueAsData = valueAsString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: valueAsData)
    }
    
    func set<T: Codable>(_ type: T.Type, value: T, key: String) {
        guard let valueAsData = try? JSONEncoder().encode(value) else { return }
        let valueAsString = String(data: valueAsData, encoding: .utf8)
        set(valueAsString, forKey: key)
        synchronize()
    }
}
