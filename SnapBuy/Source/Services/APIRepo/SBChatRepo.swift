import Foundation
import Combine

final class ChatRepository {
    static let shared = ChatRepository()
    private init() {}
    
    private var messageUpdateTimer: Timer?
    private var messageUpdateSubject = PassthroughSubject<[ChatMessage], Never>()
    var messageUpdates: AnyPublisher<[ChatMessage], Never> {
        messageUpdateSubject.eraseToAnyPublisher()
    }
    
    func startMessagePolling(userId: String) {
        stopMessagePolling()
        messageUpdateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.fetchMessages(userId: userId) { result in
                if case .success(let response) = result, let messages = response.data {
                    self?.messageUpdateSubject.send(messages)
                }
            }
        }
    }
    
    func stopMessagePolling() {
        messageUpdateTimer?.invalidate()
        messageUpdateTimer = nil
    }
    
    func fetchMessages(userId: String, completion: @escaping (Result<ChatResponse, Error>) -> Void) {
        SBAPIService.shared.performRequest(
            endpoint: "api/chat/messages/\(userId)",
            method: "GET",
            completion: completion
        )
    }
    
    func sendMessage(request: SendMessageRequest, completion: @escaping (Result<SendMessageResponse, Error>) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(request) else {
            let error = NSError(domain: "ChatRepository", code: -1005, userInfo: [NSLocalizedDescriptionKey: "Unable to encode message request"])
            completion(.failure(error))
            return
        }
        
        SBAPIService.shared.performRequest(
            endpoint: "api/chat/send",
            method: "POST",
            body: jsonData,
            completion: completion
        )
    }
} 