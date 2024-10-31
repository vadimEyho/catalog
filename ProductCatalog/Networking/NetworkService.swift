import Foundation

final class NetworkService: NetworkServiceProtocol {
    
    private let baseURL = "https://dummyjson.com"
    private let endpoint = "/products"
    private var dataTask: URLSessionDataTask?
    private let lockQueue = DispatchQueue(label: "com.networkService.lockQueue", attributes: .concurrent)
    
    func cancelFetch() {
        lockQueue.async(flags: .barrier) {
            self.dataTask?.cancel()
            self.dataTask = nil
        }
    }
    
    func fetchProducts(page: Int = 1, limit: Int = 20) async throws -> [Product] {
        let urlString = "\(baseURL + endpoint)?skip=\((page - 1) * limit)&limit=\(limit)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            cancelFetch()
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.lockQueue.async(flags: .barrier) {
                        self?.dataTask = nil
                    }
                }
                
                if let error = error as? URLError, error.code == .cancelled {
                    return
                } else if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let data = data, let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    continuation.resume(throwing: NSError(domain: "Invalid response", code: -1, userInfo: nil))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                    continuation.resume(returning: decodedResponse.products)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            lockQueue.async(flags: .barrier) {
                self.dataTask = task
            }
            
            task.resume()
        }
    }
}
