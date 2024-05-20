import Alamofire

class ChatListService {
    private let client: APIClient
    private let webSocketService: WebSocketService
    
    init(client: APIClient, webSocketService: WebSocketService) {
        self.client = client
        self.webSocketService = webSocketService
    }
    
    func fetchUserChats(userId: Int64, completion: @escaping (Result<[Chat], APIError>) -> Void) {
        let endpoint = ChatEndpoint.getChats
        client.fetch(with: endpoint, responseType: [Chat].self, completion: completion)
    }
    
    func connect() {
//        webSocketService.connect()
    }
    
    func disconnect() {
//        webSocketService.disconnect()
    }
}
