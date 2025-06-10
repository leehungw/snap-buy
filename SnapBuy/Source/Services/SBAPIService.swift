import Foundation

final class SBAPIService {
    static let shared = SBAPIService()
    
    private let baseURL: URL
    private let session: URLSession
    
    private init() {
        guard let url = URL(string: SBAppConstant.apiBaseURL) else {
            fatalError("Invalid Base URL")
        }
        self.baseURL = url
        self.session = URLSession(configuration: .default)
    }
    
    func performRequest<T: Decodable>(endpoint: String,
                                      method: String = "GET",
                                      body: Data? = nil,
                                      headers: [String: String]? = nil,
                                      completion: @escaping (Result<T, Error>) -> Void) {
        
        let request = SBAPIRequestBuilder.buildRequest(endpoint: endpoint,
                                                         method: method,
                                                         baseURL: baseURL,
                                                         body: body,
                                                         headers: headers)
        
        // Debug print request
        print("🌐 API Request:")
        print("URL:", request.url?.absoluteString ?? "")
        print("Method:", method)
        print("Headers:", headers ?? [:])
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("Body:", bodyString)
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network Error:", error)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            // Debug print response
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 Response Status Code:", httpResponse.statusCode)
            }
            
            guard let data = data else {
                print("❌ No Data Received")
                DispatchQueue.main.async {
                    let noDataError = NSError(domain: "SBAPIService", code: -1001, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(noDataError))
                }
                return
            }
            
            // Debug print raw response data
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Raw Response Data:")
                print(responseString)
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedObject))
                }
            } catch {
                print("❌ Decode Error:", error)
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key Not Found:", key)
                        print("Coding Path:", context.codingPath)
                        print("Debug Description:", context.debugDescription)
                    case .valueNotFound(let type, let context):
                        print("Value Not Found for type:", type)
                        print("Coding Path:", context.codingPath)
                        print("Debug Description:", context.debugDescription)
                    case .typeMismatch(let type, let context):
                        print("Type Mismatch for type:", type)
                        print("Coding Path:", context.codingPath)
                        print("Debug Description:", context.debugDescription)
                    case .dataCorrupted(let context):
                        print("Data Corrupted")
                        print("Coding Path:", context.codingPath)
                        print("Debug Description:", context.debugDescription)
                    @unknown default:
                        print("Unknown decoding error:", error)
                    }
                }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

struct SBAPIRequestBuilder {
    static func buildRequest(endpoint: String,
                             method: String,
                             baseURL: URL,
                             body: Data? = nil,
                             headers: [String: String]? = nil) -> URLRequest {

        var url = baseURL.appendingPathComponent(endpoint)
        if endpoint.hasPrefix(":") {
            url = URL(string: "\(baseURL.absoluteString)\(endpoint)") ?? baseURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}
