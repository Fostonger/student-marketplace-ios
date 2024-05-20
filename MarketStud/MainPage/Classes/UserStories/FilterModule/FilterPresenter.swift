class FilterPresenter {
    private weak var view: FilterViewController?
    private let service: MainPageService
    private let mainPagePresenter: MainPagePresenter
    
    var selectedFilter: SearchFilter {
        mainPagePresenter.currentFilter
    }
    
    init(
        view: FilterViewController,
        service: MainPageService,
        mainPagePresenter: MainPagePresenter
    ) {
        self.view = view
        self.service = service
        self.mainPagePresenter = mainPagePresenter
    }
    
    func fetchFilters() {
        service.fetchLocations { [weak self] result in
            switch result {
            case .success(var locations):
                locations.append(Location(id: -1, description: "Не выбрано"))
                self?.locations = locations.sorted(by: { $0.id < $1.id})
                self?.updateView()
            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
        
        service.fetchCategories { [weak self] result in
            switch result {
            case .success(var categories):
                categories.append(Category(id: -1, description: "Не выбрано"))
                self?.categories = categories.sorted(by: { $0.id < $1.id})
                self?.updateView()
            case .failure(let error):
                self?.view?.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func updateView() {
        if locations != nil && categories != nil {
            view?.updateFilters(locations: locations!, categories: categories!)
        }
    }
    
    func applyFilter(_ filter: SearchFilter) {
        mainPagePresenter.currentFilter = filter
        mainPagePresenter.reloadItems()
        view?.dismiss(animated: true)
    }
    
    private var locations: [Location]? {
        didSet { updateView() }
    }
    private var categories: [Category]? {
        didSet { updateView() }
    }
}
