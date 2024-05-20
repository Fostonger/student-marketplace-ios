import UIKit

protocol MainPageView: AnyObject {
    func configure(with items: [Item])
    func showLoading()
    func hideLoading()
    func showError(message: String)
    func updateFilters(statuses: [Status], locations: [Location], categories: [Category])
    func clearCollectionView()
}

class MainPageViewController: UIViewController, MainPageView {
    var presenter: MainPagePresenter!
    
    private let searchBar = UISearchBar()
    private let filtersButton = UIButton(type: .system)
    private let collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            return collectionView
        }()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.fetchFilters()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        searchBar.placeholder = "Search for items"
        searchBar.delegate = self
        
        filtersButton.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        filtersButton.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        filtersButton.isUserInteractionEnabled = true
        
        let stackView = UIStackView(arrangedSubviews: [searchBar, filtersButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stackView.heightAnchor.constraint(equalToConstant: 40),
            collectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func filtersButtonTapped() {
        presenter.navigateToFilters()
    }
    
    // MARK: - MainPageView Protocol
    
    func configure(with items: [Item]) {
        self.items.append(contentsOf: items)
        collectionView.reloadData()
    }
    
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
    
    func updateFilters(statuses: [Status], locations: [Location], categories: [Category]) {
        // Возможно понадобится. Пока нет :)
    }
    
    func clearCollectionView() {
        items = []
        collectionView.reloadData()
    }
}

extension MainPageViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        presenter.currentFilter.itemName = query
        presenter.reloadItems()
    }
}

extension MainPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath
        ) as? ItemCollectionViewCell else {
            return UICollectionViewCell()
        }
        let item = items[indexPath.row]
        cell.configure(with: item)
        presenter.fetchImage(itemId: item.id) { result in
            switch result {
            case .success(let imageData):
                cell.setImage(data: imageData)
            case .failure:
                cell.setImage(data: nil)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let collectionViewSize = collectionView.frame.size.width - padding * 3
        return CGSize(width: collectionViewSize / 2, height: collectionViewSize / 2 + 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath)
        if items.count - 2 == indexPath.row {
            presenter.fetchItems()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.item]
        presenter.fetchImage(itemId: selectedItem.id) { [weak self] result in
            switch result {
            case .success(let imageData):
                self?.presenter.navigateToDetailedView(
                    with: selectedItem,
                    image: UIImage(data: imageData)!
                )
            case .failure:
                break
            }
        }
    }
}
