import UIKit

class ChatTableViewCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let lastMessageLabel = UILabel()
    private let itemImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        itemImageView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        lastMessageLabel.font = UIFont.systemFont(ofSize: 14)
        lastMessageLabel.textColor = .gray

        contentView.addSubview(nameLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(itemImageView)

        NSLayoutConstraint.activate([
            
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            itemImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            itemImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            itemImageView.heightAnchor.constraint(equalToConstant: 50),
            itemImageView.widthAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            lastMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            lastMessageLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 10),
            lastMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    func configure(with imageData: Data?, item: Item?, lastMessage: String?) {
        nameLabel.text = item?.name
        if let image = imageData {
            itemImageView.image = UIImage(data: image)
        }
        lastMessageLabel.text = lastMessage
    }
}
