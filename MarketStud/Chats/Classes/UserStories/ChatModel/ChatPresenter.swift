class ChatPresenter {
    private weak var view: ChatView?
    private let service: ChatService
    private let chat: Chat
    let userId: Int64
    private var page = 0
    private let loadMoreMessagesHandler: (Int64, Int) -> ()

    init(
        view: ChatView,
        service: ChatService,
        chat: Chat,
        userId: Int64,
        chatSubscription: @escaping ( @escaping ([Message]) -> () ) -> (),
        loadMoreMessagesHandler: @escaping (Int64, Int) -> ()
    ) {
        self.view = view
        self.service = service
        self.chat = chat
        self.userId = userId
        self.loadMoreMessagesHandler = loadMoreMessagesHandler
        chatSubscription(loadedMessages)
    }
    
    func loadMoreMessages() {
        loadMoreMessagesHandler(chat.id, page)
        page += 1
    }

    func loadedMessages(_ messages: [Message]) {
        view?.updateMessages(with: messages)
    }

    func sendMessage(_ messageString: String) {
        let message = Message(
            chatId: chat.id,
            senderId: userId,
            message: messageString,
            seqNumber: 0
        )
        service.sendMessage(chatId: chat.id, message: message) { [weak self] result in
            switch result {
            case .success(let message):
                self?.loadedMessages([message])
            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
    }
}
