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
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    let noDataError = NSError(domain: "SBAPIService", code: -1001, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(.failure(noDataError))
                }
                return
            }
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedObject))
                }
            } catch let decodeError {
                DispatchQueue.main.async {
                    completion(.failure(decodeError))
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
