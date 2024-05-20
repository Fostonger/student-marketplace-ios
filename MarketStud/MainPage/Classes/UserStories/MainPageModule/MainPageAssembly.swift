import UIKit

class MainPageAssembly {
    private let service: MainPageService
    
    init(service: MainPageService) {
        self.service = service
    }
    
    func assemble() -> MainPageViewController {
        let viewController = MainPageViewController()
        let presenter = MainPagePresenter(view: viewController, service: service)
        let router = MainPageRouter(
            viewController: viewController,
            filterAssembly: FilterAssembly(service: service, mainPagePresenter: presenter)
        )
        presenter.router = router
        viewController.presenter = presenter
        return viewController
    }
}
