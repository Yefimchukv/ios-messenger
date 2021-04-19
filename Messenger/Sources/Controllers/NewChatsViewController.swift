//
//  NewChatsViewController.swift
//  Messenger
//
//  Created by Виталий Ефимчук on 14.04.2021.
//

import UIKit
import Firebase


class NewChatsViewController: UIViewController {
    
    public var completion: (([String: String]) -> (Void))?
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFetched = false
     
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
    }
}

// MARK: - Tableview description
extension NewChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatUsersCell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            self.completion?(targetUserData)
            ChatsListViewController().createNewChat(result: targetUserData)
        })
        
//        tableView.deselectRow(at: indexPath, animated: true)
//        performSegue(withIdentifier: "newUserToChat", sender: nil)
    }
}

// MARK: - Search implementation
extension NewChatsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        results.removeAll()
        
        searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        if hasFetched {
            //filter
            filterUsers(with: query)
        }
        else {
            //fetch
            
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        }
    }
    
    func filterUsers(with term: String) {
        
        guard hasFetched else {
            return
        }
        
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        })
        
        self.results = results
        
        updateUI()
        
    }
    
    func updateUI() {
        //        if !results.isEmpty {
        self.tableView.reloadData()
        //        }
    }
    
}
