import UIKit

final class ImageLoader {
    private let session = URLSession.shared
    private let cache = NSCache<NSString, UIImage>()
    
    // MARK: - Cache Management
    private func cachedImage(for urlString: String) -> UIImage? {
        return cache.object(forKey: urlString as NSString)
    }
    
    private func cacheImage(_ image: UIImage, for urlString: String) {
        cache.setObject(image, forKey: urlString as NSString)
    }
}

// MARK: - ImageLoaderProtocol Implementation
extension ImageLoader: ImageLoaderProtocol {
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check cache for existing image
        if let cachedImage = cachedImage(for: urlString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            // Check if data is valid and create image
            if let data = data, let image = UIImage(data: data) {
                // Resize image to 64x64
                let resizedImage = image.resized(to: CGSize(width: 64, height: 64), scale: UIScreen.main.scale)
                
                // Save resized image to cache
                self.cacheImage(resizedImage, for: urlString)
                
                DispatchQueue.main.async {
                    completion(resizedImage)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.priority = URLSessionTask.lowPriority
        task.resume()
    }
}

// MARK: - UIImage Extension for Resizing
extension UIImage {
    func resized(to size: CGSize, scale: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }
}
