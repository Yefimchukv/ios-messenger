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
        NewChatsViewController().completion = { [weak self] result in
            guard let self = self else { return }
            print("\(result)")
            self.createNewChat(result: result)
        }
        performSegue(withIdentifier: "newChats", sender: self)
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
