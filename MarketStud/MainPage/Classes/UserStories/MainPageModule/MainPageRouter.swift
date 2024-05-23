import UIKit

class MainPageRouter {
    private let filterAssembly: FilterAssembly
    private weak var viewController: UIViewController?
    private let itemDetailsAssembly: ItemDetailsAssembly
    
    init(viewController: UIViewController, filterAssembly: FilterAssembly, itemDetailsAssembly: ItemDetailsAssembly) {
        self.viewController = viewController
        self.filterAssembly = filterAssembly
        self.itemDetailsAssembly = itemDetailsAssembly
    }
    
    func navigateToFilters(currentFilter: SearchFilter) {
        let filterViewController = filterAssembly.assemble()
        viewController?.present(filterViewController, animated: true)
    }
    
    func navigateToDetails(with item: Item, image: UIImage) {
        let detailsView = itemDetailsAssembly.assemble(with: item, image: image)
        viewController?.navigationController?.pushViewController(detailsView, animated: true)
    }
}
