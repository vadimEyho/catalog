@MainActor
protocol ProductListViewModelProtocol {
    var products: [Product] { get }
    var isLoading: Bool { get }
    
    func setOnProductsUpdated(_ callback: @escaping () -> Void)
    func setOnError(_ callback: @escaping (Error) -> Void)
    func setOnLoadingStatusChanged(_ callback: @escaping (Bool) -> Void)
    
    func loadProducts()
    func refreshProducts()
    func loadMoreProducts()
    func cancelLoading()
}
