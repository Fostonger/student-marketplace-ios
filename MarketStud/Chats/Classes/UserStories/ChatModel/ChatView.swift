import UIKit

protocol ChatView: AnyObject {
    func updateMessages(with messages: [Message])
    func showError(message: String)
}

import UIKit

class ChatViewController: UIViewController, ChatView {
    var presenter: ChatPresenter!

    private let tableView = UITableView()
    private let messageInputBar = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    private var messages: [Message] = []
    private let item: Item

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init(messages: [Message], item: Item) {
        self.messages = messages
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = item.name

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageCell")
        
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.backgroundColor = .lightGray

        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.placeholder = "Enter message"
        messageTextField.borderStyle = .roundedRect

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        messageInputBar.addSubview(messageTextField)
        messageInputBar.addSubview(sendButton)
        view.addSubview(tableView)
        view.addSubview(messageInputBar)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor),

            messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputBar.heightAnchor.constraint(equalToConstant: 50),

            messageTextField.leadingAnchor.constraint(equalTo: messageInputBar.leadingAnchor, constant: 10),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 35),

            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 10),
            sendButton.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor)
        ])
        
        tableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: .bottom, animated: true)
    }

    @objc private func sendButtonTapped() {
        guard let messageText = messageTextField.text, !messageText.isEmpty else { return }
        presenter.sendMessage(messageText)
        messageTextField.text = ""
    }

    // MARK: - ChatView Protocol

    func updateMessages(with messages: [Message]) {
        self.messages.append(contentsOf: messages)
        self.messages = uniqueMessages(from: self.messages)
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: .bottom, animated: true)
    }
    
    private func uniqueMessages(from messages: [Message]) -> [Message] {
        var seenIDs = Set<Int64>()
        return messages.filter { message in
            if seenIDs.contains(message.seqNumber) {
                return false
            } else {
                seenIDs.insert(message.seqNumber)
                return true
            }
        }
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
        let message = messages[indexPath.row]
        cell.configure(with: message, isOwned: presenter.userId == message.senderId)
        return cell
    }
}
