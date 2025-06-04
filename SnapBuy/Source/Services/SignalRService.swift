import Foundation
import SwiftSignalRClient

class SignalRService: ObservableObject {
     var connection: HubConnection!
    @Published var receivedMessages: [String] = []


    func startSignalR() {
        // Replace with your backend URL
        let url = URL(string: "https://localhost:32681/chatHub")!

        connection = HubConnectionBuilder(url: url)
            .withLogging(minLogLevel: .debug)
            .build()

        // Lắng nghe message từ server
        connection.on(method: "NewMessage", callback: { (user: String, message: String) in
            print("Received from \(user): \(message)")
        })

        // Kết nối
        connection.start()

    }
}
