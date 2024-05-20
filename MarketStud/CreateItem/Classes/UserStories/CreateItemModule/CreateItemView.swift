import UIKit

protocol CreateItemView: AnyObject {
    func showLoading()
    func hideLoading()
    func showError(message: String)
    func showImageUploadSuccess(url: String)
    func showCreateItemSuccess()
    func updateFilters(statuses: [Status], locations: [Location], categories: [Category])
}

class CreateItemViewController: UIViewController, CreateItemView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var presenter: CreateItemPresenter!
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Item Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let priceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Price"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let locationPickerView = UIPickerView()
    private let statusPickerView = UIPickerView()
    private let categoriesPickerView = UIPickerView()
    
    private let locationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Select Location"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let statusTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Select Status"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let categoriesTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Select Categories"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Item", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var selectedPhotoURL: URL?
    private var selectedLocationId: Int64?
    private var selectedStatusId: Int64?
    private var selectedCategoryIds: [Int64] = []
    
    private var statuses: [Status] = []
    private var locations: [Location] = []
    private var categories: [Category] = []
    
    private var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.fetchFilters()
    }
    
    func setupWithGivenItem(item: Item, image: UIImage) {
        let priceDouble = Double(item.price) / 100
        itemImageView.image = image
        nameTextField.text = item.name
        descriptionTextView.text = item.description
        priceTextField.text = String(format: "%.2f", priceDouble)
        self.item = item
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        itemImageView.addGestureRecognizer(tapGestureRecognizer)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        contentView.addSubview(itemImageView)
        contentView.addSubview(nameTextField)
        contentView.addSubview(priceTextField)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(locationTextField)
        contentView.addSubview(statusTextField)
        contentView.addSubview(categoriesTextField)
        contentView.addSubview(addButton)
        contentView.addSubview(loadingIndicator)
        
        locationTextField.inputView = locationPickerView
        statusTextField.inputView = statusPickerView
        categoriesTextField.inputView = categoriesPickerView
        
        locationPickerView.delegate = self
        locationPickerView.dataSource = self
        
        statusPickerView.delegate = self
        statusPickerView.dataSource = self
        
        categoriesPickerView.delegate = self
        categoriesPickerView.dataSource = self
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            itemImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            itemImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            itemImageView.heightAnchor.constraint(equalToConstant: 200),
            
            nameTextField.topAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            priceTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10),
            priceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionTextView.topAnchor.constraint(equalTo: priceTextField.bottomAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            locationTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 10),
            locationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusTextField.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: 10),
            statusTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            categoriesTextField.topAnchor.constraint(equalTo: statusTextField.bottomAnchor, constant: 10),
            categoriesTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoriesTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addButton.topAnchor.constraint(equalTo: categoriesTextField.bottomAnchor, constant: 20),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -120),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @objc private func photoTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text,
              let priceText = priceTextField.text, let priceDouble = Double(priceText),
              let description = descriptionTextView.text,
              let selectedLocationId,
              selectedLocationId != -1,
              let selectedStatusId,
              selectedStatusId != -1,
              selectedCategoryIds.first(where: { $0 == -1 }) == nil
        else {
            showError(message: "Не все поля заполнены")
            return
        }
        let price = Int64(priceDouble*100)
        let item = Item(
            id: item != nil ? item!.id : 0,
            status: statuses.first(where: { $0.id == selectedStatusId })!,
            name: name,
            price: price,
            description: description,
            location: locations.first(where: { $0.id == selectedLocationId })!,
            categories: categories.filter { category in
                return selectedCategoryIds.contains(where: { category.id == $0 })
            },
            sellerId: 0
        )
        presenter.createItem(item)
    }
    
    // MARK: - CreateItemView Protocol
    
    func showLoading() {
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showImageUploadSuccess(url: String) {
        let alert = UIAlertController(title: "Ура!", message: "Вы успешно создали заказ! Можете посмотреть его в списке товаров", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showCreateItemSuccess() {
        guard let image = itemImageView.image else {
            showError(message: "Сначала установите картинку!")
            return
        }
        presenter.uploadImage(image)
    }
    
    func updateFilters(statuses: [Status], locations: [Location], categories: [Category]) {
        self.statuses = statuses
        self.locations = locations
        self.categories = categories
        locationPickerView.reloadAllComponents()
        locationTextField.text = locations[0].description
        statusPickerView.reloadAllComponents()
        statusTextField.text = statuses[0].description
        categoriesPickerView.reloadAllComponents()
        categoriesTextField.text = categories[0].description
        if let item {
            selectedLocationId = item.location.id
            selectedCategoryIds = item.categories.map(\.id)
            selectedStatusId = item.status.id
            let selectedLocationRow = locations.firstIndex(where: { $0.id == selectedLocationId})
            locationPickerView.selectRow(selectedLocationRow ?? 0, inComponent: 0, animated: false)
            locationTextField.text = item.location.description
            categoriesTextField.text = item.categories.reduce(into: "", { $0 += $1.description + ", " })
            statusTextField.text = item.status.description
            let selectedStatusRow = statuses.firstIndex(where: { $0.id == selectedStatusId})
            statusPickerView.selectRow(selectedStatusRow ?? 0, inComponent: 0, animated: false)
        }
    }
    
    private func clearFields() {
        itemImageView.image = nil
        nameTextField.text = ""
        priceTextField.text = ""
        descriptionTextView.text = ""
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let selectedImage = info[.originalImage] as? UIImage {
            itemImageView.image = selectedImage
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CreateItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case statusPickerView:
            return statuses.count
        case locationPickerView:
            return locations.count
        case categoriesPickerView:
            return categories.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case statusPickerView:
            return statuses[row].description
        case locationPickerView:
            return locations[row].description
        case categoriesPickerView:
            return categories[row].description
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case locationPickerView:
            selectedLocationId = locations[row].id
            locationTextField.text = locations[row].description
        case statusPickerView:
            selectedStatusId = statuses[row].id
            statusTextField.text = statuses[row].description
        case categoriesPickerView:
            let selectedCategory = categories[row]
            if selectedCategoryIds.contains(selectedCategory.id) {
                selectedCategoryIds.removeAll { $0 == selectedCategory.id }
            } else if selectedCategory.id == -1 {
                selectedCategoryIds.removeAll()
                selectedCategoryIds.append(selectedCategory.id)
            } else {
                selectedCategoryIds.removeAll { $0 == -1 }
                selectedCategoryIds.append(selectedCategory.id)
            }
            categoriesTextField.text = selectedCategoryIds.map { id in categories.first { $0.id == id }!.description }.joined(separator: ", ")
        default:
            break
        }
    }
}
