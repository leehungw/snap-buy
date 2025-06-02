import Foundation

final class ReviewRepository {
    static let shared = ReviewRepository()
    private init() {}
    
    private let baseURL = "http://localhost"
    
    func submitReview(
        orderId: String,
        productId: Int,
        rating: Int,
        content: String,
        images: [String],
        productNote: String,
        completion: @escaping (Result<ReviewData, Error>) -> Void
    ) {
        print("📝 Submitting review for product \(productId) in order \(orderId)")
        
        // Get current user
        guard let currentUser = UserRepository.shared.currentUser else {
            completion(.failure(NSError(domain: "ReviewRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let request = ReviewRequest(
            id: 0,
            orderId: orderId,
            productId: productId,
            starNumber: rating,
            reviewComment: content,
            productReviewImages: images,
            productNote: productNote,
            userId: currentUser.id
        )
        
        // Debug print request data
        if let requestData = try? JSONEncoder().encode(request),
           let requestJson = String(data: requestData, encoding: .utf8) {
            print("📤 Request JSON:")
            print(requestJson)
        }
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "product/api/productReviews",
            method: "POST",
            body: try? JSONEncoder().encode(request),
            headers: headers
        ) { [weak self] (result: Result<ReviewResponse, Error>) in
            // Debug print response
            print("📥 Response received:")
            switch result {
            case .success(let response):
                print("✅ Success response:")
                print("Result code:", response.result)
                if let data = response.data {
                    print("Review data:", data)
                }
                if let error = response.error {
                    print("Error in response:", error)
                }
                
                if response.result == 1, var reviewData = response.data {
                    // Fetch user data
                    UserRepository.shared.fetchUserById(userId: reviewData.userId) { userResult in
                        switch userResult {
                        case .success(let userData):
                            // Convert UserData to ReviewUserData
                            reviewData.user = ReviewUserData(
                                id: userData.id,
                                name: userData.name,
                                imageURL: userData.imageURL,
                                userName: userData.userName,
                                email: userData.email,
                                lastProductId: userData.lastProductId
                            )
                            completion(.success(reviewData))
                        case .failure(let error):
                            print("⚠️ Failed to fetch user data: \(error.localizedDescription)")
                            // Even if user fetch fails, still return the review data
                            reviewData.user = ReviewUserData(
                                id: currentUser.id,
                                name: currentUser.name,
                                imageURL: currentUser.imageURL,
                                userName: currentUser.userName,
                                email: currentUser.email,
                                lastProductId: currentUser.lastProductId
                            )
                            completion(.success(reviewData))
                        }
                    }
                } else if let error = response.error {
                    completion(.failure(NSError(
                        domain: "ReviewRepository",
                        code: error.code,
                        userInfo: [NSLocalizedDescriptionKey: error.message ?? "Failed to submit review"]
                    )))
                } else {
                    completion(.failure(NSError(
                        domain: "ReviewRepository",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to submit review"]
                    )))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchProductReviews(productId: Int, completion: @escaping (Result<[ProductReview], Error>) -> Void) {
        print("📝 Fetching reviews for product: \(productId)")
        
        let headers = ["Content-Type": "application/json"]
        
        SBAPIService.shared.performRequest(
            endpoint: "product/api/productReviews/product/\(productId)",
            method: "GET",
            body: nil,
            headers: headers
        ) { [weak self] (result: Result<ProductReviewResponse, Error>) in
            switch result {
            case .success(let response):
                if response.result == 1 || (response.result == -1 && !response.data.isEmpty) {
                    print("✅ Successfully fetched \(response.data.count) reviews")
                    
                    // Create a dispatch group to wait for all user data
                    let group = DispatchGroup()
                    var reviews = response.data
                    var errors: [Error] = []
                    
                    // Fetch user data for each review
                    for (index, review) in reviews.enumerated() where review.user == nil && review.userId != "00000000-0000-0000-0000-000000000000" {
                        group.enter()
                        UserRepository.shared.fetchUserById(userId: review.userId) { userResult in
                            defer { group.leave() }
                            
                            switch userResult {
                            case .success(let userData):
                                // Convert UserData to ReviewUserData
                                let reviewUserData = ReviewUserData(
                                    id: userData.id,
                                    name: userData.name,
                                    imageURL: userData.imageURL,
                                    userName: userData.userName,
                                    email: userData.email,
                                    lastProductId: userData.lastProductId
                                )
                                // Update the review with user data
                                reviews[index] = ProductReview(
                                    id: review.id,
                                    productId: review.productId,
                                    starNumber: review.starNumber,
                                    orderId: review.orderId,
                                    productNote: review.productNote,
                                    userId: review.userId,
                                    reviewComment: review.reviewComment,
                                    productReviewImages: review.productReviewImages,
                                    user: reviewUserData
                                )
                            case .failure(let error):
                                print("⚠️ Failed to fetch user data for review: \(error.localizedDescription)")
                                errors.append(error)
                            }
                        }
                    }
                    
                    // When all user data is fetched
                    group.notify(queue: .main) {
                        // Even if some user fetches failed, we still return the reviews
                        completion(.success(reviews))
                    }
                } else {
                    print("✅ No reviews found")
                    completion(.success([]))
                }
            case .failure(let error):
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
} 
