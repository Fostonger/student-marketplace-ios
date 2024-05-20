import UIKit

class MainPageRouter {
    private let filterAssembly: FilterAssembly
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController, filterAssembly: FilterAssembly) {
        self.viewController = viewController
        self.filterAssembly = filterAssembly
        
    }
    
    func navigateToFilters(currentFilter: SearchFilter) {
        let filterViewController = filterAssembly.assemble()
        viewController?.present(filterViewController, animated: true)
    }
    
    func navigateToDetails(with item: Item, image: UIImage) {
        let detailsView = ItemDetailsAssembly().assemble(with: item, image: image)
        viewController?.navigationController?.pushViewController(detailsView, animated: true)
    }
}
