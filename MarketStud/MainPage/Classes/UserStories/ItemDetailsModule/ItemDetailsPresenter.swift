import UIKit

class ItemDetailsPresenter {
    private weak var view: ItemDetailsView?
    private let item: Item
    private let image: UIImage
    private let router: ItemDetailsRouter
    
    init(view: ItemDetailsView, item: Item, image: UIImage, router: ItemDetailsRouter) {
        self.view = view
        self.item = item
        self.image = image
        self.router = router
    }
    
    func fetchItemDetails() {
        view?.configure(with: item, image: image)
    }
    
    func navigateToChat() {
        router.navigateToChat(with: item.sellerId)
    }
}
