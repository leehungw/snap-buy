import Foundation

// Request Models
struct SendTextRequest: Codable {
    let userSendId: String
    let userReceiveId: String
    let message: String
}

struct SendImageRequest: Codable {
    let userSendId: String
    let userReceiveId: String
    let imageData: Data
}

struct SendVideoRequest: Codable {
    let userSendId: String
    let userReceiveId: String
    let videoData: Data
}

// Response Models
struct ChatRoom: Codable, Identifiable {
    let id: Int
    let userId: String
    let name: String
    let avatar: String
    let lastMessage: String?
    let lastMessageTime: Date
}

struct ChatMessage: Codable, Identifiable, Equatable {
    let id: Int
    let userSendId: String
    let avatar: String
    let message: String
    let mediaLink: String?
    let sendDate: Date
    let type: MessageType
    
    var isUser: Bool {
        userSendId == UserRepository.shared.currentUser?.id
    }
    
    var timeString: String {
        DateFormatter.localizedString(from: sendDate, dateStyle: .none, timeStyle: .short)
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.userSendId == rhs.userSendId &&
        lhs.message == rhs.message &&
        lhs.mediaLink == rhs.mediaLink &&
        lhs.sendDate == rhs.sendDate &&
        lhs.type == rhs.type
    }
}

enum MessageType: String, Codable {
    case text = "Text"
    case image = "Image"
    case video = "Video"
}

// API Response Wrappers
struct APIError: Codable {
    let code: Int
    let message: String
}

struct ChatRoomsResponse: Codable {
    let result: Int
    let data: [ChatRoom]?
    let error: APIError?
}

struct ChatMessagesResponse: Codable {
    let result: Int
    let data: [ChatMessage]?
    let error: APIError?
}

struct SendMessageResponse: Codable {
    let result: Int
    let data: ChatMessage?
    let error: APIError?
} 