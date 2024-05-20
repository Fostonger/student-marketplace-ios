import UIKit

class CreateItemAssembly: ItemDetailsAssemblyProtocol {
    private let service: CreateItemService
    
    init(service: CreateItemService) {
        self.service = service
    }
    
    func assemble() -> CreateItemViewController {
        let viewController = CreateItemViewController()
        let router = CreateItemRouter(viewController: viewController)
        let presenter = CreateItemPresenter(view: viewController, service: service, router: router)
        viewController.presenter = presenter
        return viewController
    }
    
    func assemble(with item: Item, image: UIImage) -> UIViewController {
        let viewController = assemble()
        viewController.setupWithGivenItem(item: item, image: image)
        return viewController
    }
}
