protocol NetworkServiceProtocol {
    func fetchProducts(page: Int, limit: Int) async throws -> [Product]
    func cancelFetch()
}
