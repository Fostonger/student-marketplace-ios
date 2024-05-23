import UIKit

class ItemDetailsPresenter {
    private weak var view: ItemDetailsView?
    private let item: Item
    private let image: UIImage
    private let router: ItemDetailsRouter
    private let service: MainPageService
    private let userId: Int64
    
    init(view: ItemDetailsView, item: Item, image: UIImage, router: ItemDetailsRouter, service: MainPageService, userId: Int64) {
        self.view = view
        self.item = item
        self.image = image
        self.router = router
        self.service = service
        self.userId = userId
    }
    
    func fetchItemDetails() {
        view?.configure(with: item, image: image)
    }
    
    func navigateToChat() {
        let chat = Chat(id: -1, itemId: item.id, customerId: userId)
        service.createChat(chat) { [weak self] result in
            switch result {
            case .success(let chat):
                self?.router.navigateTo(chat: chat)
            case .failure(let failure):
                self?.view?.showError(message: failure.localizedDescription)
            }
        }
    }
}
