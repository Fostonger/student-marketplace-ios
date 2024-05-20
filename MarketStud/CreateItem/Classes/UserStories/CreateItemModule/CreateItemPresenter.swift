import Foundation
import UIKit

class CreateItemPresenter {
    private weak var view: CreateItemView?
    private let service: CreateItemService
    private let router: CreateItemRouter
    
    private var statuses: [Status] = []
    private var locations: [Location] = []
    private var categories: [Category] = []
    private var itemId: Int64?
    
    
    init(view: CreateItemView, service: CreateItemService, router: CreateItemRouter) {
        self.view = view
        self.service = service
        self.router = router
    }
    
    func uploadImage(_ image: UIImage) {
        guard let itemId else { return }
        view?.showLoading()
        service.uploadImage(image, for: itemId) { [weak self] result in
            self?.view?.hideLoading()
            switch result {
            case .success(let imageUrl):
                self?.view?.showImageUploadSuccess(url: imageUrl)
            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    func createItem(_ item: Item) {
        view?.showLoading()
        service.createItem(item) { [weak self] result in
            self?.view?.hideLoading()
            switch result {
            case .success(let item):
                self?.itemId = item.id
                self?.view?.showCreateItemSuccess()
            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    func fetchFilters() {
        view?.showLoading()
        
        let dispatchGroup = DispatchGroup()
        
        var fetchError: APIError?
        
        dispatchGroup.enter()
        service.fetchStatuses { [weak self] result in
            switch result {
            case .success(var data):
                data.append(Status(id: -1, description: "Статус не выбран"))
                self?.statuses = data.sorted(by: { $0.id < $1.id})
            case .failure(let error):
                fetchError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        service.fetchLocations { [weak self] result in
            switch result {
            case .success(var data):
                data.append(Location(id: -1, description: "Место не выбрано"))
                self?.locations = data.sorted(by: { $0.id < $1.id})
            case .failure(let error):
                fetchError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        service.fetchCategories { [weak self] result in
            switch result {
            case .success(var data):
                data.append(Category(id: -1, description: "Категорий не выбрано"))
                self?.categories = data.sorted(by: { $0.id < $1.id})
            case .failure(let error):
                fetchError = error
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.view?.hideLoading()
            if let error = fetchError {
                self?.view?.showError(message: error.localizedDescription)
            } else {
                guard let self else { return }
                self.view?.updateFilters(statuses: self.statuses, locations: self.locations, categories: self.categories)
            }
        }
    }
}
