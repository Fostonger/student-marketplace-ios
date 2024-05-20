import UIKit

class ProfileRouter {
    private weak var viewController: UIViewController?
    private let createItemAssembly: ItemDetailsAssemblyProtocol
    private let logoutHandler: () -> ()

    init(
        viewController: UIViewController,
        createItemAssembly: ItemDetailsAssemblyProtocol,
        logoutHandler: @escaping () -> ()
    ) {
        self.viewController = viewController
        self.createItemAssembly = createItemAssembly
        self.logoutHandler = logoutHandler
    }

    func navigateToItemDetails(item: Item, image: UIImage) {
        let itemDetailsVC = createItemAssembly.assemble(with: item, image: image)
        viewController?.navigationController?.pushViewController(itemDetailsVC, animated: true)
    }

    func navigateToLogin() {
        logoutHandler()
    }
}
