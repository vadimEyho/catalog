import UIKit

final class AppDependencyContainer {
    /// Creates the root view controller with all dependencies injected
    @MainActor
    func makeRootViewController() -> UIViewController {
        let networkService = makeNetworkService()
        let imageLoader = makeImageLoader()
        let viewModel = makeProductListViewModel(networkService: networkService)
        return makeProductListViewController(viewModel: viewModel, imageLoader: imageLoader)
    }
    
    // MARK: - Factory Methods
    private func makeProductListViewController(viewModel: ProductListViewModel, imageLoader: ImageLoaderProtocol) -> ProductListViewController {
        return ProductListViewController(viewModel: viewModel, imageLoader: imageLoader)
    }
    
    @MainActor
    private func makeProductListViewModel(networkService: NetworkServiceProtocol) -> ProductListViewModel {
        return ProductListViewModel(networkService: networkService)
    }
    
    private func makeNetworkService() -> NetworkServiceProtocol {
        return NetworkService()
    }
    
    private func makeImageLoader() -> ImageLoaderProtocol {
        return ImageLoader()
    }
}
