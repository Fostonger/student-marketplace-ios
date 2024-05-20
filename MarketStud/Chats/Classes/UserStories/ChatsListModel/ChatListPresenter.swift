class ChatListPresenter {
    private weak var view: ChatListView?
    private let service: ChatListService
    private let router: ChatListRouter
    private let userId: Int64
    
    init(view: ChatListView, service: ChatListService, router: ChatListRouter, userId: Int64) {
        self.view = view
        self.service = service
        self.router = router
        self.userId = userId
    }
    
    func fetchChats() {
        service.fetchUserChats(userId: userId) { [weak self] result in
            switch result {
            case .success(let chats):
                self?.view?.updateChatList(chats: chats)
            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    func connect() {
        service.connect()
    }
    
    func disconnect() {
        service.disconnect()
    }
    
    func navigateToChat(with chat: Chat) {
        router.navigateToChat(with: chat)
    }
}
