import UIKit

class ItemDetailsRouter {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func navigateToChat(with sellerId: Int64) {
        viewController?.tabBarController?.selectedIndex = 2
    }
}
