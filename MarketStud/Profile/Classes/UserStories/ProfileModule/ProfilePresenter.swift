import Foundation
import UIKit

class ProfilePresenter {
    private weak var view: ProfileView?
    private let service: ProfileService
    private let router: ProfileRouter
    
    private var page: Int = 0
    private var statuses: [Status] = []
    private var locations: [Location] = []
    private var categories: [Category] = []
    private var finishedLoading = false
    private var currentlyLoading = false

    init(view: ProfileView, service: ProfileService, router: ProfileRouter) {
        self.view = view
        self.service = service
        self.router = router
    }

    func loadProfile() {
        service.fetchUserProfile() { [weak self] result in
            switch result {
            case .success(let user):
                self?.view?.updateProfile(with: user)
            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    func reloadView() {
        page = 0
        finishedLoading = false
        loadUserItems()
    }

    func loadUserItems() {
        if finishedLoading || currentlyLoading {
            return
        }
        currentlyLoading = true
        fetchFilters { [weak self] _ in
            guard let self else { return }
            self.service.fetchUserItems(currentPage: self.page) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    switch result {
                    case .success(let itemsDto):
                        self.page += 1
                        self.finishedLoading = itemsDto.isEmpty
                        let items = itemsDto.map { dto in
                            Item(
                                id: dto.id,
                                status: self.statuses.first(where: { $0.id == dto.status_id})!,
                                name: dto.name, price: dto.price, description: dto.description,
                                location: self.locations.first(where: { $0.id == dto.location_id})!,
                                categories: dto.categories_ids.map { category_id in
                                    self.categories.first(where: { $0.id == category_id})!
                                },
                                sellerId: dto.seller_id
                            )
                        }
                        self.view?.updateItems(with: items)
                    case .failure(let error):
                        self.view?.showError(message: error.localizedDescription)
                    }
                    self.currentlyLoading = false
                }
            }
        }
    }
    
    func navigateToItemDetails(item: Item, image: UIImage) {
        router.navigateToItemDetails(item: item, image: image)
    }
    
    func fetchImage(itemId: Int64, completion: @escaping (Result<Data, APIError>) -> ()) {
        service.fetchImage(itemId: itemId, completion: completion)
    }
    
    func fetchFilters(completion: @escaping (Result<String, APIError>) -> ()) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        service.fetchStatuses { [weak self] result in
            switch result {
            case .success(let success):
                self?.statuses = success
            case .failure:
                break
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        service.fetchLocations { [weak self] result in
            switch result {
            case .success(let success):
                self?.locations = success
            case .failure:
                break
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        service.fetchCategories { [weak self] result in
            switch result {
            case .success(let success):
                self?.categories = success
            case .failure:
                break
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(""))
        }
    }

    func logout() {
        router.navigateToLogin()
    }
}
