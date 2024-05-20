class ChatService {
    private let webSocketService: WebSocketService
    
    init(webSocketService: WebSocketService) {
        self.webSocketService = webSocketService
    }
    
    func connect() {
//        webSocketService.connect()
    }
    
    func disconnect() {
//        webSocketService.disconnect()
    }
    
    func sendMessage(_ message: String) {
//        webSocketService.sendMessage(message)
    }
}
