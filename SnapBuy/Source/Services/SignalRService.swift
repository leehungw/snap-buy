import Foundation
import SwiftSignalRClient

class SignalRService: ObservableObject {
    var chatConnection: HubConnection?
    var notificationConnection: HubConnection?
    @Published var receivedMessages: [String] = []
    @Published var receivedNotifications: [String] = []

    func startSignalR() {
        // Replace with your backend URL
        let url = URL(string: "https://localhost:32681/chatHub")!

        chatConnection = HubConnectionBuilder(url: url)
            .withLogging(minLogLevel: .debug)
            .build()

        // Lắng nghe message từ server
        chatConnection?.on(method: "NewMessage", callback: { (user: String, message: String) in
            print("Received from \(user): \(message)")
        })

        // Kết nối
        chatConnection?.start()
    }

    // New notification SignalR
    func startNotificationSignalR(onNotification: ((String) -> Void)? = nil) {
        let url = URL(string: "http://localhost:32682/notificationHub")!
        notificationConnection = HubConnectionBuilder(url: url)
            .withLogging(minLogLevel: .debug)
            .build()
        notificationConnection?.on(method: "NewNoti", callback: { (user: String) in
            print("[NotificationHub] Received notification for userId=\(user)")
            onNotification?(user)
        })
        notificationConnection?.start()
    }
}
