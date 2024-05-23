import Foundation

class ChatService {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchChats(userId: Int64, page: Int, completion: @escaping (Result<[Chat], APIError>) -> Void) {
        let endpoint = ChatEndpoint.getChats(userId: userId, page: page)
        client.fetch(with: endpoint, responseType: [Chat].self, completion: completion)
    }

    func fetchMessages(chatId: Int64, page: Int, completion: @escaping (Result<[Message], APIError>) -> Void) {
        let endpoint = ChatEndpoint.getMessages(chatId: chatId, page: page)
        client.fetch(with: endpoint, parameters: Optional<Int>.none, responseType: [Message].self, completion: completion)
    }
    
    func createChat(chat: Chat, completion: @escaping (Result<Chat, APIError>) -> Void) {
        let endpoint = ChatEndpoint.createChat
        client.fetch(with: endpoint, parameters: chat, responseType: Chat.self, completion: completion)
    }

    func sendMessage(chatId: Int64, message: Message, completion: @escaping (Result<Message, APIError>) -> Void) {
        let endpoint = ChatEndpoint.sendMessage
        client.fetch(with: endpoint, parameters: message, responseType: Message.self, completion: completion)
    }
    
    func pollMessages(lastKnownId: Int64, userId: Int64, completion: @escaping (Result<[Message], APIError>) -> Void) {
        let endpoint = ChatEndpoint.pollMessages(userId: userId, lastKnownMessageId: lastKnownId)
        client.fetch(with: endpoint, responseType: [Message].self, completion: completion)
    }
    
    func fetchItem(
        itemId: Int64,
        completion: @escaping (Result<ItemDTO, APIError>) -> Void
    ) {
        let endpoint = ItemEndpoint.fetchOneItem(itemId: itemId)
        client.fetch(with: endpoint, responseType: ItemDTO.self, completion: completion)
    }
    
    func fetchImage(itemId: Int64, completion: @escaping (Result<Data, APIError>) -> Void) {
        let endpoint = ItemEndpoint.fetchImage(itemId: itemId)
        client.downloadData(
            with: endpoint
        ) { result in
            switch result {
            case .success(let imageData):
                let photoMetadata = Photo(id: itemId, seqNumber: 0, photoPath: endpoint.urlString)
                let image = PhotoWithImage(
                    id: itemId,
                    photoMetadata: photoMetadata,
                    image: imageData
                )
                completion(.success(imageData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchStatuses(completion: @escaping (Result<[Status], APIError>) -> Void) {
        let endpoint = StatusEndpoint.status
        client.fetch(with: endpoint, responseType: [Status].self, completion: completion)
    }
    
    func fetchLocations(completion: @escaping (Result<[Location], APIError>) -> Void) {
        let endpoint = LocationEndpoint.location
        client.fetch(with: endpoint, responseType: [Location].self, completion: completion)
    }
    
    func fetchCategories(completion: @escaping (Result<[Category], APIError>) -> Void) {
        let endpoint = CategoryEndpoint.categories
        client.fetch(with: endpoint, responseType: [Category].self, completion: completion)
    }
}
