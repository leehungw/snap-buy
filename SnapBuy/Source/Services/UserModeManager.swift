import Foundation
import Combine

enum UserMode {
    case buyer
    case seller
}

final class UserModeManager: ObservableObject {
    static let shared = UserModeManager()
    
    private init() {
        // Check if user is premium and set initial mode
        if let user = UserRepository.shared.currentUser, user.isPremium {
            currentMode = .seller
        } else {
            currentMode = .buyer
        }
    }
    
    @Published private(set) var currentMode: UserMode
    
    func switchMode() {
        guard let user = UserRepository.shared.currentUser, user.isPremium else {
            currentMode = .buyer
            return
        }
        
        currentMode = currentMode == .buyer ? .seller : .buyer
    }
} 
