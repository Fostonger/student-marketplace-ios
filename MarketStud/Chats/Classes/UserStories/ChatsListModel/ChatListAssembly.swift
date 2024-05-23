import UIKit

class ChatListAssembly {
    private let apiClient: APIClient
    private let userId: Int64
    private let chatDeeplinkProvider: (ChatDeeplink) -> ()

    init(apiClient: APIClient, userId: Int64, chatDeeplinkProvider: @escaping (ChatDeeplink) -> ()) {
        self.apiClient = apiClient
        self.userId = userId
        self.chatDeeplinkProvider = chatDeeplinkProvider
    }

    func assemble() -> ChatListViewController {
        let service = ChatService(client: apiClient)
        let viewController = ChatListViewController()
        let chatAssembly = ChatAssembly(apiClient: apiClient, userId: userId)
        let router = ChatListRouter(viewController: viewController, chatAssembly: chatAssembly)
        let presenter = ChatListPresenter(view: viewController, service: service, router: router, userId: userId)
        chatDeeplinkProvider(presenter)
        viewController.presenter = presenter
        return viewController
    }
}

