import UIKit

class ChatAssembly {
    private let service: WebSocketService
    
    init(service: WebSocketService) {
        self.service = service
    }
    
    func assemble(chat: Chat) -> ChatViewController {
        let service = ChatService(webSocketService: service)
        let viewController = ChatViewController()
        let presenter = ChatPresenter(view: viewController, service: service, chat: chat)
        viewController.presenter = presenter
        return viewController
    }
}
