import Foundation

final class ProductListViewModel: ProductListViewModelProtocol {
    
    // MARK: - Properties
    private let networkService: NetworkServiceProtocol
    private(set) var products = [Product]()
    private var currentPage = 1
    private let itemsPerPage = 20
    private(set) var isLoading = false
    
    // MARK: - Callbacks
    private var onProductsUpdated: (() -> Void)?
    private var onError: ((Error) -> Void)?
    private var onLoadingStatusChanged: ((Bool) -> Void)?
    
    // MARK: - Initializer
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Callback Setters
    func setOnProductsUpdated(_ callback: @escaping () -> Void) {
        onProductsUpdated = callback
    }
    
    func setOnError(_ callback: @escaping (Error) -> Void) {
        onError = callback
    }
    
    func setOnLoadingStatusChanged(_ callback: @escaping (Bool) -> Void) {
        onLoadingStatusChanged = callback
    }
    
    // MARK: - Data Loading
    func loadProducts() {
        Task {
            await loadProductsInternal()
        }
    }
    
    private func loadProductsInternal() async {
        guard !isLoading else { return }
        
        isLoading = true
        onLoadingStatusChanged?(true)
        
        defer {
            isLoading = false
            onLoadingStatusChanged?(false)
        }
        
        do {
            let newProducts = try await networkService.fetchProducts(page: currentPage, limit: itemsPerPage)
            products.append(contentsOf: newProducts)
            DispatchQueue.main.async { [weak self] in
                self?.onProductsUpdated?()
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.handleError(error)
            }
        }
    }
    
    // MARK: - Pagination & Refresh
    func refreshProducts() {
        currentPage = 1
        products.removeAll()
        loadProducts()
    }
    
    func loadMoreProducts() {
        guard !isLoading else { return }
        currentPage += 1
        loadProducts()
    }
    
    // MARK: - Cancel
    func cancelLoading() {
        networkService.cancelFetch()
        isLoading = false
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        onError?(error)
    }
}
