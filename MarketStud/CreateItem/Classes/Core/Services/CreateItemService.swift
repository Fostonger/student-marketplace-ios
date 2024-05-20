import Alamofire

struct PhotoUploadResponse: Codable {
    let filename: String
}

class CreateItemService {
    private let client: APIClient
    private let isNew: Bool
    private let userId: Int64
    
    init(client: APIClient, isNew: Bool, userId: Int64) {
        self.client = client
        self.isNew = isNew
        self.userId = userId
    }
    
    func uploadImage(_ image: UIImage, for itemid: Int64, completion: @escaping (Result<String, APIError>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(APIError.dataCorrupted(message: "Слишком большая картинка")))
            return
        }
        
        let endpoint = isNew ? ItemEndpoint.loadImage : ItemEndpoint.updateImage
        client.uploadPhoto(
            with: endpoint,
            data: imageData,
            itemId: itemid
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.filename))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createItem(_ item: Item, completion: @escaping (Result<ItemDTO, APIError>) -> Void) {
        let endpoint = isNew ? ItemEndpoint.saveItem : ItemEndpoint.updateItem
        let itemDto = ItemDTO(
            id: item.id,
            status_id: item.status.id,
            name: item.name,
            price: item.price,
            description: item.description,
            location_id: item.location.id,
            categories_ids: item.categories.map(\.id),
            seller_id: userId
        )
        client.fetch(with: endpoint, parameters: itemDto, responseType: ItemDTO.self, completion: completion)
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
