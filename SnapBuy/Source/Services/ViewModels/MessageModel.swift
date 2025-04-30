import SwiftUI

struct User: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct Message: Identifiable {
    let id = UUID()
    let sender: User
    let content: String
    let timeAgo: String
    let unreadCount: Int
}
let sampleUsers = [
    User(name: "Kristine", imageName: "cat_access"),
    User(name: "Kay", imageName: "cat_access"),
    User(name: "Cheryl", imageName: "cat_access"),
    User(name: "Jeen", imageName: "cat_access")
]

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let time: String
    let isUser: Bool
}

let sampleMessages = [
    Message(sender: User(name: "Jhone Endrue", imageName: "cat_access"),
            content: "Hello hw are you? I am going to market. Do you want shopping?",
            timeAgo: "23 min", unreadCount: 2),
    
    Message(sender: User(name: "Jihane Luande", imageName: "cat_access"),
            content: "We are on the runways at the military hangar, there is a plane in it.",
            timeAgo: "40 min", unreadCount: 1),
    
    Message(sender: User(name: "Broman Alexander", imageName: "cat_access"),
            content: "I received my new watch that I ordered from Amazon.",
            timeAgo: "1 hr", unreadCount: 0),
    
    Message(sender: User(name: "Zack Jr", imageName: "cat_access"),
            content: "I just arrived in front of the school. I’m waiting for you hurry up!",
            timeAgo: "1 hr", unreadCount: 0)
]
let sampleChatMessages: [ChatMessage] = [
    ChatMessage(text: "Hi, I have purchased this product", time: "10.10 AM", isUser: true),
    ChatMessage(text: "Ahmir has paid $1,100...", time: "", isUser: true),
    ChatMessage(text: "Send it soon ok!", time: "10.15 AM", isUser: true),
    ChatMessage(text: "Hi Ahmir, Thanks for buying our product", time: "10.30 AM", isUser: false),
    ChatMessage(text: "Your package will be packed soon", time: "10.31 AM", isUser: false),
]
