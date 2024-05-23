import UIKit

class ChatAssembly {
    private let apiClient: APIClient
    private let userId: Int64

    init(apiClient: APIClient, userId: Int64) {
        self.apiClient = apiClient
        self.userId = userId
    }

    func assemble(
        chat: Chat,
        messages: [Message],
        item: Item,
        chatSubscription: @escaping ( @escaping ([Message]) -> () ) -> (),
        loadMoreMessagesHandler: @escaping (Int64, Int) -> ()
    ) -> ChatViewController {
        let service = ChatService(client: apiClient)
        let viewController = ChatViewController(messages: messages, item: item)
        let presenter = ChatPresenter(
            view: viewController,
            service: service,
            chat: chat,
            userId: userId,
            chatSubscription: chatSubscription,
            loadMoreMessagesHandler: loadMoreMessagesHandler
        )
        viewController.presenter = presenter
        return viewController
    }
}
