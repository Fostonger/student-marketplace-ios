import UIKit

protocol ProfileView: AnyObject {
    func updateProfile(with user: User)
    func updateItems(with items: [Item])
    func showError(message: String)
}

class ProfileViewController: UIViewController, ProfileView {
    var presenter: ProfilePresenter!

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let logoutButton = UIButton(type: .system)
    private lazy var itemsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let padding: CGFloat = 20
        let collectionViewSize = view.frame.size.width - 20 - padding * 3
        layout.itemSize = CGSize(width: collectionViewSize / 2, height: collectionViewSize / 2 + 60)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = false
        return collectionView
    }()

    private var items: [Item] = []
    private var heightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.loadProfile()
        presenter.loadUserItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        items = []
        itemsCollectionView.reloadData()
        presenter.reloadView()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Profile"

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        contentView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .gray

        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        usernameLabel.font = UIFont.systemFont(ofSize: 18)
        usernameLabel.textColor = .gray

        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.red, for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)

        itemsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        itemsCollectionView.delegate = self
        itemsCollectionView.dataSource = self
        itemsCollectionView.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        itemsCollectionView.backgroundColor = .white

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(logoutButton)
        contentView.addSubview(itemsCollectionView)
        
        heightConstraint = itemsCollectionView.heightAnchor.constraint(equalToConstant: 0)

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

            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            usernameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            logoutButton.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            itemsCollectionView.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20),
            itemsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            itemsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            itemsCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            heightConstraint
        ])
    }

    @objc private func logoutButtonTapped() {
        presenter.logout()
    }

    // MARK: - ProfileView Protocol

    func updateProfile(with user: User) {
        nameLabel.text = "\(user.name) \(user.familyName)"
        usernameLabel.text = user.username
    }

    func updateItems(with newItems: [Item]) {
        let collectionViewSize = max(itemsCollectionView.frame.size.width, 200) - 60
        let collectionViewHeight = collectionViewSize / 2 + 60
        let totalItemsCount = CGFloat(items.count + newItems.count)
        heightConstraint.constant = ((totalItemsCount / 2 + 1).rounded(.up) * collectionViewHeight)
        itemsCollectionView.layoutIfNeeded()
        
        let startIndex = items.count
        let endIndex = startIndex + newItems.count
        let indexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
        
        self.items.append(contentsOf: newItems)
        
        itemsCollectionView.performBatchUpdates({
            itemsCollectionView.insertItems(at: indexPaths)
        }, completion: nil)
        
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        presenter.fetchImage(itemId: selectedItem.id) { [weak self] result in
            switch result {
            case .success(let imageData):
                self?.presenter.navigateToItemDetails(
                    item: selectedItem,
                    image: UIImage(data: imageData)!
                )
            case .failure:
                break
            }
        }
    }
}

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if contentOffsetY > contentHeight - frameHeight * 2 {
            presenter.loadUserItems()
        }
    }
}
