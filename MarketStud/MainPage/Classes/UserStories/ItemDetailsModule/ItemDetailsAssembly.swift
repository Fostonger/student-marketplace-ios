import UIKit

protocol ItemDetailsAssemblyProtocol: AnyObject {
    func assemble(with: Item, image: UIImage) -> UIViewController
}

class ItemDetailsAssembly {
    
    init() {
    }
    
    func assemble(with item: Item, image: UIImage) -> ItemDetailsViewController {
        let viewController = ItemDetailsViewController()
        let router = ItemDetailsRouter(viewController: viewController)
        let presenter = ItemDetailsPresenter(
            view: viewController,
            item: item,
            image: image,
            router: router
        )
        viewController.presenter = presenter
        return viewController
    }
}
