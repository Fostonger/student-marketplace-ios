import Foundation
import UIKit

class MainPagePresenter {
    private weak var view: MainPageView?
    private let service: MainPageService
    private var currentItemPage = 0
    private var locations: [Location] = []
    private var categories: [Category] = []
    private var statuses: [Status] = []
    private var loading = false
    private var endData = false
    var router: MainPageRouter!
    var currentFilter = SearchFilter()
    
    init(view: MainPageView, service: MainPageService) {
        self.view = view
        self.service = service
        fetchFilters()
    }
    
    func fetchItems() {
        if endData || loading { return }
        view?.showLoading()
        loading = true
        service.fetchItems(currentPage: currentItemPage, filter: currentFilter) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.view?.hideLoading()
                switch result {
                case .success(let itemsDto):
                    self.endData = itemsDto.isEmpty
                    self.currentItemPage += 1
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
                    self.view?.configure(with: items)
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                }
                self.loading = false
            }
        }
    }
    
    func fetchImage(itemId: Int64, completion: @escaping (Result<Data, APIError>) -> ()) {
        service.fetchImage(itemId: itemId, completion: completion)
    }
    
    func reloadItems() {
        currentItemPage = 0
        view?.clearCollectionView()
        fetchItems()
    }
    
    func fetchFilters() {
        view?.showLoading()
        
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
            self?.view?.hideLoading()
            self?.fetchItems()
        }
    }
    
    func navigateToDetailedView(with item: Item, image: UIImage) {
        router.navigateToDetails(with: item, image: image)
    }
    
    func navigateToFilters() {
        router.navigateToFilters(currentFilter: currentFilter)
    }
}

