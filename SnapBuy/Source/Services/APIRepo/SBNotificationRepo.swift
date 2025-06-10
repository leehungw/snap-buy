import Foundation

struct SBNotification: Codable, Identifiable {
    let id: Int
    let userId: String
    let userInvoke: String
    let message: String
    let orderId: String?
    let productId: Int?
    let eventType: String
    let isAlreadySeen: Bool
}

struct SBNotificationResponse: Codable {
    let result: Int
    let data: [SBNotification]?
    let error: APIErrorResponse?
}

final class NotificationRepository {
    static let shared = NotificationRepository()
    private init() {}

    func fetchNotifications(for userId: String, completion: @escaping (Result<[SBNotification], Error>) -> Void) {
        let endpoint = "notification/api/notifications/\(userId)"
        SBAPIService.shared.performRequest(
            endpoint: endpoint,
            method: "GET",
            body: nil,
            headers: nil
        ) { (result: Result<SBNotificationResponse, Error>) in
            switch result {
            case .success(let response):
                if let notifications = response.data {
                    completion(.success(notifications))
                } else {
                    let message = response.error?.message ?? "No notifications returned"
                    let err = NSError(
                        domain: "NotificationRepository",
                        code: response.error?.code ?? -1,
                        userInfo: [NSLocalizedDescriptionKey: message]
                    )
                    completion(.failure(err))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
} 