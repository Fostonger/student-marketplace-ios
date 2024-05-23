import UIKit

class MessageTableViewCell: UITableViewCell {
    private let messageLabel = UILabel()
    
    private var leadingMessageAnchor: NSLayoutConstraint!
    private var trailingMessageAnchor: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0

        contentView.addSubview(messageLabel)
        
        leadingMessageAnchor = messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        trailingMessageAnchor = messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            leadingMessageAnchor,
            trailingMessageAnchor,
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with message: Message, isOwned: Bool) {
        messageLabel.text = message.message
        if isOwned {
            leadingMessageAnchor.constant = 60
            trailingMessageAnchor.constant = -10
            contentView.backgroundColor = .cyan
            messageLabel.textAlignment = .right
        } else  {
            leadingMessageAnchor.constant = 10
            trailingMessageAnchor.constant = -60
            contentView.backgroundColor = .lightGray
            messageLabel.textAlignment = .left
        }
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
}
