import Alamofire

class ProfileService {
    private let client: APIClient
    private let userId: Int64
    private var page = 0

    init(client: APIClient, for userId: Int64) {
        self.client = client
        self.userId = userId
    }

    func fetchUserProfile(completion: @escaping (Result<User, APIError>) -> Void) {
        let endpoint = ProfileEndpoint.user(id: userId)
        client.fetch(with: endpoint, parameters: Optional<Int>.none, responseType: User.self, completion: completion)
    }
    
    func fetchUserItems(
        currentPage: Int,
        completion: @escaping (Result<[ItemDTO], APIError>) -> Void
    ) {
        let filter = SearchFilter(seller: userId)
        let endpoint = ItemEndpoint.fetchItem(page: currentPage, filter: filter)
        client.fetch(with: endpoint, responseType: [ItemDTO].self, completion: completion)
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
