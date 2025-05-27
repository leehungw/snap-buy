import Foundation

struct ChatMessage: Codable, Identifiable, Equatable {
    let id: String
    let senderId: String
    let receiverId: String
    let text: String
    let timestamp: Date
    
    var isUser: Bool {
        senderId == UserRepository.shared.currentUser?.id
    }
    
    var timeString: String {
        DateFormatter.localizedString(from: timestamp, dateStyle: .none, timeStyle: .short)
    }
}

struct SendMessageRequest: Codable {
    let receiverId: String
    let text: String
}

struct ChatResponse: Codable {
    let result: Int
    let data: [ChatMessage]?
    let error: APIErrorResponse?
}

struct SendMessageResponse: Codable {
    let result: Int
    let data: ChatMessage?
    let error: APIErrorResponse?
} 