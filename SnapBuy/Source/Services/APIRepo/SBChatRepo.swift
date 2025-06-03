import Foundation
import Combine

final class ChatRepository {
    static let shared = ChatRepository()
    private init() {}
    
    private var messageUpdateSubject = PassthroughSubject<[ChatMessage], Never>()
    private var chatRoomsUpdateSubject = PassthroughSubject<[ChatRoom], Never>()
    
    var messageUpdates: AnyPublisher<[ChatMessage], Never> {
        messageUpdateSubject.eraseToAnyPublisher()
    }
    
    var chatRoomsUpdates: AnyPublisher<[ChatRoom], Never> {
        chatRoomsUpdateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - SignalR Setup
    func startRealtimeUpdates(selectedChatId: String?, userId: String) {
        SignalRService.shared.connectToChat(selectedChatId: selectedChatId, myId: userId) { chatRoomId, userId in
            // When new message arrives, fetch both messages and chat rooms
            // This exactly matches the React implementation
            if let selectedChatId = selectedChatId {
                self.fetchChatMessages(chatRoomId: selectedChatId) { result in
                    if case .success(let response) = result, let messages = response.data {
                        self.messageUpdateSubject.send(messages)
                    }
                }
            }
            
            self.fetchChatRooms(userId: userId) { result in
                if case .success(let response) = result, let rooms = response.data {
                    self.chatRoomsUpdateSubject.send(rooms)
                }
            }
        }
    }
    
    func stopRealtimeUpdates() {
        SignalRService.shared.disconnectFromChat()
    }
    
    // MARK: - Chat Rooms
    func fetchChatRooms(userId: String, completion: @escaping (Result<ChatRoomsResponse, Error>) -> Void) {
        SBAPIService.shared.performRequest(
            endpoint: "chat/api/chats/\(userId)",
            method: "GET",
            completion: completion
        )
    }
    
    // MARK: - Chat Messages
    func fetchChatMessages(chatRoomId: String, completion: @escaping (Result<ChatMessagesResponse, Error>) -> Void) {
        SBAPIService.shared.performRequest(
            endpoint: "chat/api/chats/chatRoom/\(chatRoomId)",
            method: "GET",
            completion: completion
        )
    }
    
    // MARK: - Send Messages
    func sendText(request: SendTextRequest, completion: @escaping (Result<SendMessageResponse, Error>) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            let error = NSError(domain: "ChatRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"])
            completion(.failure(error))
            return
        }
        
        SBAPIService.shared.performRequest(
            endpoint: "chat/api/chats/sendText",
            method: "POST",
            body: jsonData,
            completion: completion
        )
    }
    
    func sendImage(request: SendImageRequest, completion: @escaping (Result<SendMessageResponse, Error>) -> Void) {
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var data = Data()
        
        // Add text fields
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"userSendId\"\r\n\r\n")
        data.append("\(request.userSendId)\r\n")
        
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"userReceiveId\"\r\n\r\n")
        data.append("\(request.userReceiveId)\r\n")
        
        // Add image data
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
        data.append("Content-Type: image/jpeg\r\n\r\n")
        data.append(request.imageData)
        data.append("\r\n")
        
        data.append("--\(boundary)--\r\n")
        
        SBAPIService.shared.performRequest(
            endpoint: "chat/api/chats/sendImage",
            method: "POST",
            body: data,
            headers: ["Content-Type": "multipart/form-data; boundary=\(boundary)"],
            completion: completion
        )
    }
    
    func sendVideo(request: SendVideoRequest, completion: @escaping (Result<SendMessageResponse, Error>) -> Void) {
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var data = Data()
        
        // Add text fields
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"userSendId\"\r\n\r\n")
        data.append("\(request.userSendId)\r\n")
        
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"userReceiveId\"\r\n\r\n")
        data.append("\(request.userReceiveId)\r\n")
        
        // Add video data
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"video\"; filename=\"video.mp4\"\r\n")
        data.append("Content-Type: video/mp4\r\n\r\n")
        data.append(request.videoData)
        data.append("\r\n")
        
        data.append("--\(boundary)--\r\n")
        
        SBAPIService.shared.performRequest(
            endpoint: "chat/api/chats/sendVideo",
            method: "POST",
            body: data,
            headers: ["Content-Type": "multipart/form-data; boundary=\(boundary)"],
            completion: completion
        )
    }
}

// MARK: - Data Extensions
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
} 