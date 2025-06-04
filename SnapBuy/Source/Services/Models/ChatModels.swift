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
    let type: MessageType
    
    var chatRoomId: String { String(id) }
    
    enum CodingKeys: String, CodingKey {
        case id, userId, name, avatar, lastMessage, lastMessageTime, type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        avatar = try container.decode(String.self, forKey: .avatar)
        lastMessage = try container.decodeIfPresent(String.self, forKey: .lastMessage)
        type = try container.decodeIfPresent(MessageType.self, forKey: .type) ?? .text
        
        // Custom date decoding
        let dateString = try container.decode(String.self, forKey: .lastMessageTime)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            lastMessageTime = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .lastMessageTime,
                                                  in: container,
                                                  debugDescription: "Date string does not match expected format")
        }
    }
}

struct ChatMessage: Codable, Identifiable, Equatable {
    let id: Int
    let userSendId: String
    let avatar: String?
    let message: String?
    let mediaLink: String?
    let sendDate: Date
    let type: MessageType
    
    var isUser: Bool {
        userSendId == UserRepository.shared.currentUser?.id
    }
    
    var timeString: String {
        DateFormatter.localizedString(from: sendDate, dateStyle: .none, timeStyle: .short)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, userSendId, avatar, message, mediaLink, sendDate, type
    }
    
    init(id: Int, userSendId: String, avatar: String?, message: String?, mediaLink: String?, sendDate: Date, type: MessageType) {
        self.id = id
        self.userSendId = userSendId
        self.avatar = avatar
        self.message = message
        self.mediaLink = mediaLink
        self.sendDate = sendDate
        self.type = type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userSendId = try container.decode(String.self, forKey: .userSendId)
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        mediaLink = try container.decodeIfPresent(String.self, forKey: .mediaLink)
        type = try container.decode(MessageType.self, forKey: .type)
        
        // Custom date decoding
        let dateString = try container.decode(String.self, forKey: .sendDate)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            sendDate = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .sendDate,
                                                  in: container,
                                                  debugDescription: "Date string does not match expected format")
        }
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