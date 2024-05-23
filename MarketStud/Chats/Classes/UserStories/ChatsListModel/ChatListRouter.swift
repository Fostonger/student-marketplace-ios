import UIKit

class ChatListRouter {
    private weak var viewController: UIViewController?
    private let chatAssembly: ChatAssembly

    init(viewController: UIViewController, chatAssembly: ChatAssembly) {
        self.viewController = viewController
        self.chatAssembly = chatAssembly
    }

    func navigateToChat(
        chat: Chat,
        messages: [Message],
        item: Item,
        subscription: @escaping ( @escaping ([Message]) -> () ) -> (),
        loadMoreMessagesHandler: @escaping (Int64, Int) -> ()
    ) {
        let chatVC = chatAssembly.assemble(
            chat: chat,
            messages: messages,
            item: item,
            chatSubscription: subscription,
            loadMoreMessagesHandler: loadMoreMessagesHandler
        )
        viewController?.navigationController?.pushViewController(chatVC, animated: true)
    }
}
