import Alamofire
import Foundation

final class MainPageService {
    private let client: APIClient
    private let storage: IStorage
    
    init(client: APIClient, storage: IStorage) {
        self.client = client
        self.storage = storage
    }
    
    func fetchItems(
        currentPage: Int,
        filter: SearchFilter,
        completion: @escaping (Result<[ItemDTO], APIError>) -> Void
    ) {
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
        let cachedStatus = storage.fetch(Status.self, predicate: nil, limit: nil)
        guard cachedStatus.isEmpty else {
            completion(.success(cachedStatus))
            return
        }
        client.fetch(with: endpoint, responseType: [Status].self) { [weak self] result in
            switch result {
            case .success(let statuses):
                self?.storage.replaceAll(statuses.sorted(by: { $0.id < $1.id }))
                completion(.success(statuses))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    func fetchLocations(completion: @escaping (Result<[Location], APIError>) -> Void) {
        let endpoint = LocationEndpoint.location
        let cachedLocation = storage.fetch(Location.self, predicate: nil, limit: nil)
        guard cachedLocation.isEmpty else {
            completion(.success(cachedLocation))
            return
        }
        client.fetch(with: endpoint, responseType: [Location].self) { [weak self] result in
            switch result {
            case .success(let location):
                self?.storage.replaceAll(location.sorted(by: { $0.id < $1.id }))
                completion(.success(location))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    func fetchCategories(completion: @escaping (Result<[Category], APIError>) -> Void) {
        let endpoint = CategoryEndpoint.categories
        let cachedCategory = storage.fetch(Category.self, predicate: nil, limit: nil)
        guard cachedCategory.isEmpty else {
            completion(.success(cachedCategory))
            return
        }
        client.fetch(with: endpoint, responseType: [Category].self) { [weak self] result in
            switch result {
            case .success(let category):
                self?.storage.replaceAll(category.sorted(by: { $0.id < $1.id }))
                completion(.success(category))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}
