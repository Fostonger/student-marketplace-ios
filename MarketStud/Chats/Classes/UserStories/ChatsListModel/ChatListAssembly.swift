import UIKit

class ChatListAssembly {
    private let apiClient: APIClient
    private let webSocketService: WebSocketService
    private let chatAssembly: ChatAssembly
    
    init(apiClient: APIClient, webSocketService: WebSocketService, chatAssembly: ChatAssembly) {
        self.apiClient = apiClient
        self.webSocketService = webSocketService
        self.chatAssembly = chatAssembly
    }
    
    func assemble(userId: Int64) -> ChatListViewController {
        let service = ChatListService(client: apiClient, webSocketService: webSocketService)
        let viewController = ChatListViewController()
        let router = ChatListRouter(viewController: viewController, chatAssembly: chatAssembly)
        let presenter = ChatListPresenter(view: viewController, service: service, router: router, userId: userId)
        viewController.presenter = presenter
        return viewController
    }
}
