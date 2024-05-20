import UIKit

final class FilterAssembly {
    private let service: MainPageService
    private let mainPagePresenter: MainPagePresenter
    
    init(
        service: MainPageService,
        mainPagePresenter: MainPagePresenter
    ) {
        self.service = service
        self.mainPagePresenter = mainPagePresenter
    }
    
    func assemble() -> UIViewController {
        let view = FilterViewController()
        let presenter = FilterPresenter(
            view: view,
            service: service,
            mainPagePresenter: mainPagePresenter
        )
        view.presenter = presenter
        return view
    }
}
