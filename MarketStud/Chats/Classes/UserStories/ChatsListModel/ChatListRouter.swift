import UIKit

class ChatListRouter {
    private weak var viewController: UIViewController?
    private let chatAssembly: ChatAssembly
    
    init(
        viewController: UIViewController,
        chatAssembly: ChatAssembly
    ) {
        self.viewController = viewController
        self.chatAssembly = chatAssembly
    }
    
    func navigateToChat(with chat: Chat) {
        let chatViewController = chatAssembly.assemble(chat: chat)
        viewController?.navigationController?.pushViewController(chatViewController, animated: true)
    }
}
