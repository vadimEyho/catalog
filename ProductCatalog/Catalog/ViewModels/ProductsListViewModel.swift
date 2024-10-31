import Foundation

@MainActor
class ProductListViewModel {
    private let networkService: NetworkServiceProtocol
    private(set) var products = [Product]()
    private var currentPage = 1
    private let itemsPerPage = 20
    private(set) var isLoading = false
    
    var onProductsUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onLoadingStatusChanged: ((Bool) -> Void)?
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
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
    
    func cancelLoading() {
        networkService.cancelFetch()
        isLoading = false
    }
    
    private func handleError(_ error: Error) {
        onError?(error)
    }
}
