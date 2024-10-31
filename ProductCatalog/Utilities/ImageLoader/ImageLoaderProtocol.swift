import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from url: String, completion: @escaping (UIImage?) -> Void)
}
