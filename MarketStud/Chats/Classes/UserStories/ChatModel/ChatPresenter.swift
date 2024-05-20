class ChatPresenter {
    private weak var view: ChatView?
    private let service: ChatService
    private let chat: Chat
    
    init(view: ChatView, service: ChatService, chat: Chat) {
        self.view = view
        self.service = service
        self.chat = chat
    }
    
    func connect() {
        service.connect()
    }
    
    func disconnect() {
        service.disconnect()
    }
    
    func sendMessage(_ message: String) {
        service.sendMessage(message)
    }
}
