//
//  ChatsViewController.swift
//  Messenger
//
//  Created by Виталий Ефимчук on 12.04.2021.
//

import UIKit
import Firebase

class ChatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func newChatButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "newChats", sender: self)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
