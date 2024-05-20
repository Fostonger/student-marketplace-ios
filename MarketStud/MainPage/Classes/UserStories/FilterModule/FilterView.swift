import UIKit

protocol FilterView: AnyObject {
    func configure(with filters: SearchFilter)
    func updateFilters(locations: [Location], categories: [Category])
    func showError(message: String)
}

final class FilterViewController: UIViewController, FilterView {
    var presenter: FilterPresenter!
    
    private let categoryPicker = UIPickerView()
    private let locationPicker = UIPickerView()
    private let applyButton = UIButton()
    
    private var locations: [Location] = []
    private var categories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.fetchFilters()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        locationPicker.delegate = self
        locationPicker.dataSource = self
        
        
        applyButton.setTitle("Apply", for: .normal)
        applyButton.backgroundColor = .systemBlue
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [categoryPicker, locationPicker, applyButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = true
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    @objc private func applyButtonTapped() {
        let filter = SearchFilter(
            itemName: nil, 
            category: categories[categoryPicker.selectedRow(inComponent: 0)],
            location: locations[locationPicker.selectedRow(inComponent: 0)],
            seller: nil
        )
        presenter.applyFilter(filter)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - FilterView Protocol
    
    func configure(with filters: SearchFilter) {
        // Update the UI with the current filters
    }
    
    func updateFilters(locations: [Location], categories: [Category]) {
        self.locations = locations
        let selectedLocationRow = locations.firstIndex(where: { $0.id == presenter.selectedFilter.location?.id ?? -1})
        locationPicker.selectRow(selectedLocationRow ?? 0, inComponent: 0, animated: false)
        self.categories = categories
        let selectedCategoryRow = categories.firstIndex(where: { $0.id == presenter.selectedFilter.category?.id ?? -1})
        categoryPicker.selectRow(selectedCategoryRow ?? 0, inComponent: 0, animated: false)
        categoryPicker.reloadAllComponents()
        locationPicker.reloadAllComponents()
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case categoryPicker:
            return categories.count
        case locationPicker:
            return locations.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case categoryPicker:
            return categories[row].description
        case locationPicker:
            return locations[row].description
        default:
            return nil
        }
    }
}
