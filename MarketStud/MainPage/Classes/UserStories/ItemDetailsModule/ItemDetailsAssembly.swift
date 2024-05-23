import UIKit

protocol ItemDetailsAssemblyProtocol: AnyObject {
    func assemble(with: Item, image: UIImage) -> UIViewController
}

class ItemDetailsAssembly {
    private let service: MainPageService
    private let userId: Int64
    private let chatDeeplink: ChatDeeplink?
    
    init(service: MainPageService, userId: Int64, chatDeeplink: ChatDeeplink?) {
        self.service = service
        self.userId = userId
        self.chatDeeplink = chatDeeplink
    }
    
    func assemble(with item: Item, image: UIImage) -> ItemDetailsViewController {
        let viewController = ItemDetailsViewController()
        let router = ItemDetailsRouter(viewController: viewController, chatDeeplink: chatDeeplink)
        let presenter = ItemDetailsPresenter(
            view: viewController,
            item: item,
            image: image,
            router: router,
            service: service,
            userId: userId
        )
        viewController.presenter = presenter
        return viewController
    }
}
