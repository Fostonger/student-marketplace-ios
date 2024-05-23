import UIKit

protocol ChatListView: AnyObject {
    func updateChats(with chats: [Chat])
    func showError(message: String)
}

import UIKit

import UIKit

class ChatListViewController: UIViewController, ChatListView {
    var presenter: ChatListPresenter!

    private let tableView = UITableView()
    private var chats: [Chat] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.fetchAll()
    }

    private func setupUI() {
        title = "Chats"
        view.backgroundColor = .white

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - ChatsListView Protocol

    func updateChats(with chats: [Chat]) {
        self.chats = chats
        tableView.reloadData()
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableViewCell
        let chatData = presenter?.itemAndImage(for: chats[indexPath.row])
        cell.configure(with: chatData?.0, item: chatData?.1, lastMessage: chatData?.2)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedChat = chats[indexPath.row]
        presenter.selectChat(chat: selectedChat)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
