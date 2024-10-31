import Foundation

struct ProductResponse: Decodable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}

struct Product: Decodable {
    let title: String
    let description: String
    let price: Double
    let thumbnail: String
}

