import Foundation

protocol ChatDeeplink {
    func openChatFromDeeplink(_ chat: Chat)
}

class ChatListPresenter: ChatDeeplink {
    private weak var view: ChatListView?
    private let service: ChatService
    private let router: ChatListRouter
    private let userId: Int64
    
    private var page = 0
    private var lastKnownMessageId: Int64 = 0
    private var chatMessages: [Int64 : [Message]] = [ : ]
    private var chatDelegates: [Int64 : ([Message]) -> ()] = [ : ]
    private var chats: [Chat] = []
    
    private var items: [Int64 : Item] = [:]
    private var photos: [Int64 : Data] = [ : ]
    
    private var locations: [Location] = []
    private var categories: [Category] = []
    private var statuses: [Status] = []
    
    private var promisedChat: Chat? = nil

    init(view: ChatListView, service: ChatService, router: ChatListRouter, userId: Int64) {
        self.view = view
        self.service = service
        self.router = router
        self.userId = userId
    }
    
    func openChatFromDeeplink(_ chat: Chat) {
        promisedChat = chat
        loadChats()
    }

    private func loadChats() {
        service.fetchChats(userId: userId, page: page) { [weak self] result in
            switch result {
            case .success(let chats):
                self?.page += 1
                for chat in chats {
                    self?.loadItem(for: chat)
                }
                self?.chats = chats
            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func loadItem(for chat: Chat) {
        service.fetchItem(itemId: chat.itemId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let dto):
                let item = Item(
                    id: dto.id,
                    status: self.statuses.first(where: { $0.id == dto.status_id})!,
                    name: dto.name, price: dto.price, description: dto.description,
                    location: self.locations.first(where: { $0.id == dto.location_id})!,
                    categories: dto.categories_ids.map { category_id in
                        self.categories.first(where: { $0.id == category_id})!
                    },
                    sellerId: dto.seller_id
                )
                self.items[chat.id] = item
                self.fetchImage(itemId: item.id, chatId: chat.id)
            case .failure(let failure):
                self.view?.showError(message: failure.localizedDescription)
            }
        }
    }
    
    private func fetchImage(itemId: Int64, chatId: Int64) {
        service.fetchImage(itemId: itemId) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let imageData):
                self.photos[chatId] = imageData
                self.view?.updateChats(with: chats)
                self.longPollMessages()
                if let promised = self.promisedChat {
                    self.selectChat(chat: promised)
                    self.promisedChat = nil
                }
            case .failure(let failure):
                self.view?.showError(message: failure.localizedDescription)
            }
        }
    }

    func selectChat(chat: Chat) {
        router.navigateToChat(
            chat: chat,
            messages: chatMessages[chat.id] ?? [],
            item: items[chat.id]!
        ) { [weak self] subscribtion in
            self?.chatDelegates[chat.id] = subscribtion
        } loadMoreMessagesHandler: { [weak self] (chatId, page) in
            self?.service.fetchMessages(chatId: chatId, page: page) { [weak self] result in
                switch result {
                case .success(let messages):
                    self?.processMessages(messages)
                case .failure(let failure):
                    break
                }
            }
        }
    }
    
    private func processMessages(_ messages: [Message]) {
        var newMessages: [Int64 : [Message]] = [:]
        for message in messages {
            chatMessages.appendOrAddNew(value: message, forKey: message.chatId)
            newMessages.appendOrAddNew(value: message, forKey: message.chatId)
            if chatMessages[message.chatId] == nil {
                loadChats()
            }
            if message.seqNumber > lastKnownMessageId {
                lastKnownMessageId = message.seqNumber
            }
        }
        for (chatId, messages) in newMessages {
            chatDelegates[chatId]?(messages)
        }
        
        if !newMessages.isEmpty {
            view?.updateChats(with: chats)
        }
    }
    
    private func longPollMessages() {
        service.pollMessages(lastKnownId: lastKnownMessageId, userId: userId) { [weak self] result in
            switch result {
            case .success(let messages):
                self?.processMessages(messages)
                self?.longPollMessages()
            case .failure(let failure):
                self?.view?.showError(message: failure.localizedDescription)
            }
        }
    }
    
    func itemAndImage(for chat: Chat) -> (Data?, Item?, String?) {
        return (photos[chat.id], items[chat.id], chatMessages[chat.id]?.max(by: { $0.seqNumber < $1.seqNumber })?.message)
    }
    
    func fetchAll() {
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        service.fetchStatuses { [weak self] result in
            switch result {
            case .success(let success):
                self?.statuses = success
            case .failure(let failure):
                break
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        service.fetchLocations { [weak self] result in
            switch result {
            case .success(let success):
                self?.locations = success
            case .failure(let failure):
                break
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        service.fetchCategories { [weak self] result in
            switch result {
            case .success(let success):
                self?.categories = success
            case .failure(let failure):
                break
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.loadChats()
        }
    }
}

private extension Dictionary {
    mutating func appendOrAddNew<ArrayType>(value: ArrayType, forKey: Key) where Dictionary.Value == Array<ArrayType> {
        if keys.contains(where: { $0 == forKey }) {
            self[forKey]!.append(value)
        } else {
            self[forKey] = [value]
        }
    }
}
