//
//  ChatsListViewController.swift
//  Messenger
//
//  Created by Виталий Ефимчук on 12.04.2021.
//

import UIKit
import Firebase

class ChatsListViewController: UIViewController {
    private var chats = [Chat]()
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        
        startListeningForChats()
    }
    
    private func startListeningForChats() {
        spinner.startAnimating()
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let chatsT):
                guard !chatsT.isEmpty else {
                    print("chats empty")
                    return
                }
                
                self?.chats = chatsT
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.tableView.isHidden = false
                    self?.spinner.hidesWhenStopped = true
                    self?.spinner.stopAnimating()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @IBAction func newChatButtonPressed(_ sender: UIBarButtonItem) {
        let vc = NewChatsViewController()
        vc.completion = { [weak self] result in
            self?.createNewChat(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    public func createNewChat(result: [String: String ]) {
        
        guard let name = result["name"],
              let email = result["email"] else {
            return
        }
        
        let vc = ChatViewController(with: email, id: nil)
        vc.isNewChat = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChatsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as! ChatTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = chats[indexPath.row]
        
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
}
