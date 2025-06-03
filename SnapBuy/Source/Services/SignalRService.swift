import Foundation
import SwiftSignalRClient
import Combine

final class SignalRService: ObservableObject {
    static let shared = SignalRService()
    private var connection: HubConnection?
    @Published private(set) var isConnected = false

    // Closure to handle chat room updates
    var onChatRoomUpdate: ((_ chatRoomId: String, _ userId: String) -> Void)?

    private init() {}

    func setupConnection(selectedChatId: String?, myId: String) {
        guard let url = URL(string: "https://localhost:32681/chatHub") else { return }

        connection = HubConnectionBuilder(url: url)
            .withAutoReconnect()
            .withHttpConnectionOptions { options in
                options.headers = [
                    "Accept": "application/json",
                    "Content-Type": "application/json"
                ]
                options.skipNegotiation = true
            }
            .build()

        connection?.on(method: "NewMessage") { [weak self] _ in
            guard let self = self,
                  let selectedChatId = selectedChatId else { return }

            DispatchQueue.main.async {
                self.onChatRoomUpdate?(selectedChatId, myId)
            }
        }

        startConnection()
    }

    func startConnection() {
        do {
            try connection?.start()
            print("Connected to SignalR hub")
        } catch {
            print("Error connecting to SignalR hub:", error)
        }
    }

    func stopConnection() {
        connection?.stop()
        print("Disconnected from SignalR hub")
    }

    deinit {
        stopConnection()
    }
}

// MARK: - Usage Example in View
extension SignalRService {
    func connectToChat(selectedChatId: String?, myId: String, onUpdate: @escaping (_ chatRoomId: String, _ userId: String) -> Void) {
        // Store the update handler
        self.onChatRoomUpdate = onUpdate

        // Setup and start connection
        setupConnection(selectedChatId: selectedChatId, myId: myId)
    }

    func disconnectFromChat() {
        stopConnection()
        onChatRoomUpdate = nil
    }
}
