import UIKit

final class AppDependencyContainer {
    
    // Метод для создания rootViewController со всеми зависимостями
    @MainActor
    func makeRootViewController() -> UIViewController {
        let networkService = makeNetworkService()
        let imageLoader = makeImageLoader()
        let viewModel = makeProductListViewModel(networkService: networkService)
        return makeProductListViewController(viewModel: viewModel, imageLoader: imageLoader)
    }
    
    // Фабричный методы:
    
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
