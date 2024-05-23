import UIKit

class ItemDetailsRouter {
    private weak var viewController: UIViewController?
    private let chatDeeplink: ChatDeeplink?
    
    init(viewController: UIViewController, chatDeeplink: ChatDeeplink?) {
        self.viewController = viewController
        self.chatDeeplink = chatDeeplink
    }
    
    func navigateTo(chat: Chat) {
        chatDeeplink?.openChatFromDeeplink(chat)
        viewController?.tabBarController?.selectedIndex = 2
    }
}
