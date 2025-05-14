import SwiftUI

enum NotificationType {
    case order
    case message
    case sale
    case shipment
}

struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    let timeAgo: String
    let replyText: String?
}

let notifications: [NotificationItem] = [
    NotificationItem(
        type: .order,
        title: "Purchase Completed!",
        message: "You have successfully purchased 334 headphones, thank you and wait for your package to arrive ✨",
        timeAgo: "2 m ago",
        replyText: nil
    ),
    NotificationItem(
        type: .message,
        title: "Jerremy Send You a Message",
        message: "hello your package has almost arrived, are you at home now?",
        timeAgo: "2 m ago",
        replyText: "Reply the message"
    ),
    NotificationItem(
        type: .sale,
        title: "Flash Sale!",
        message: "Get 20% discount for first transaction in this month! 😍",
        timeAgo: "2 m ago",
        replyText: nil
    ),
    NotificationItem(
        type: .shipment,
        title: "Package Sent",
        message: "Hi your package has been sent from New York",
        timeAgo: "10 m ago",
        replyText: nil
    )
]
