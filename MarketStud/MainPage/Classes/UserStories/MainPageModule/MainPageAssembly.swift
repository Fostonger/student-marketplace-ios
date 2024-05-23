import UIKit

class MainPageAssembly {
    private let service: MainPageService
    private let userId: Int64
    private let chatDeeplink: ChatDeeplink?
    
    init(service: MainPageService, userId: Int64, chatDeeplink: ChatDeeplink?) {
        self.service = service
        self.userId = userId
        self.chatDeeplink = chatDeeplink
    }
    
    func assemble() -> MainPageViewController {
        let viewController = MainPageViewController()
        let presenter = MainPagePresenter(view: viewController, service: service)
        let router = MainPageRouter(
            viewController: viewController,
            filterAssembly: FilterAssembly(service: service, mainPagePresenter: presenter),
            itemDetailsAssembly: ItemDetailsAssembly(service: service, userId: userId, chatDeeplink: chatDeeplink)
        )
        presenter.router = router
        viewController.presenter = presenter
        return viewController
    }
}
