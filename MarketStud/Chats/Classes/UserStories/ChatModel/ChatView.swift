import UIKit

protocol ChatView: AnyObject {
    func updateMessages(messages: [Message])
    func showError(message: String)
}

import UIKit

class ChatViewController: UIViewController, ChatView {
    var presenter: ChatPresenter!
    private var messages: [Message] = []
    private let tableView = UITableView()
    private let messageInputBar = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.connect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.disconnect()
    }
    
    private func setupUI() {
        title = "Chat"
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        messageInputBar.backgroundColor = .lightGray
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        
        messageTextField.placeholder = "Enter message"
        messageTextField.borderStyle = .roundedRect
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            messageTextField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 10),
            sendButton.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func sendButtonTapped() {
        guard let message = messageTextField.text, !message.isEmpty else { return }
        presenter.sendMessage(message)
        messageTextField.text = ""
    }
    
    // MARK: - ChatView Protocol
    
    func updateMessages(messages: [Message]) {
        self.messages = messages
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.message
        return cell
    }
}
