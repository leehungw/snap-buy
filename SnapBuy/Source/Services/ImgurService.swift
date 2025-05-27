private let imageKitPrivateKey = "private_Ia9HpSef3ItTQnhUgtgD3uhsayI="

import Foundation
import UIKit

struct ImgurUploadResponse: Codable {
    let data: ImgurData
    let success: Bool
    let status: Int
}

struct ImgurData: Codable {
    let link: String?
    let url: String?

    var imageLink: String {
        return link ?? url ?? ""
    }

    private enum CodingKeys: String, CodingKey {
        case link
        case url
    }
}

class ImgurService {
    static let shared = ImgurService()
    private init() {}
    
    private let uploadEndpoint = "https://upload.imagekit.io/api/v1/files/upload"
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // convert image to data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImgurService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }

        // build multipart request
        var request = URLRequest(url: URL(string: uploadEndpoint)!)
        request.httpMethod = "POST"

        // Add Basic Authorization header
        let credentials = "\(imageKitPrivateKey):"
        if let credData = credentials.data(using: .utf8) {
            let base64Creds = credData.base64EncodedString()
            request.setValue("Basic \(base64Creds)", forHTTPHeaderField: "Authorization")
        }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        // file field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"upload.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        // fileName field (optional)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"fileName\"\r\n\r\n".data(using: .utf8)!)
        body.append("upload.jpg\r\n".data(using: .utf8)!)
        // close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "ImgurService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            // decode ImageKit response
            struct ImageKitResponse: Codable {
                let url: String
            }
            do {
                let ik = try JSONDecoder().decode(ImageKitResponse.self, from: data)
                completion(.success(ik.url))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func uploadImages(_ images: [UIImage], completion: @escaping (Result<[String], Error>) -> Void) {
        var uploadedLinks: [String] = []
        let group = DispatchGroup()
        var uploadError: Error?
        
        for image in images {
            group.enter()
            uploadImage(image) { result in
                switch result {
                case .success(let link):
                    uploadedLinks.append(link)
                case .failure(let error):
                    uploadError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = uploadError {
                print(error)
                completion(.failure(error))
            } else {
                print(uploadedLinks)
                completion(.success(uploadedLinks))
            }
        }
    }
}
