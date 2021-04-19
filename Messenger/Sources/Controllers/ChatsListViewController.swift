//
//  ChatsListViewController.swift
//  Messenger
//
//  Created by Виталий Ефимчук on 12.04.2021.
//

import UIKit
import Firebase

class ChatsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        performSegue(withIdentifier: "userToChat", sender: self)
    }
}

extension ChatsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "users")
        
        cell?.textLabel?.text = "Yukinai"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "userToChat", sender: self)
    }
    
    
}
