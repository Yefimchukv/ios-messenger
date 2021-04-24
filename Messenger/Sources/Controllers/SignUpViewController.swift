//
//  SignUpViewController.swift
//  Messenger
//
//  Created by Виталий Ефимчук on 12.04.2021.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func editingPasswordStopped(_ sender: UITextField) {
        sender.text = ""
        sender.placeholder = "Enter again, please"
    }
    
    @IBAction func creatingAccountFinished(_ sender: UITextField) {
        
        guard let firstName = firstName.text, let lastName = lastName.text, let username = username.text, let email = email.text, let password = password.text  else {
            print("Check your information, please")
            return
        }
        
        // MARK: - May not work correctly
        DatabaseManager.shared.userExists(with: email) { exists in
            guard !exists else {
                print("User already exists")
                return
            }
            // MARK: -
            
            Auth.auth().createUser(withEmail: email, password: password) {[weak self] (authResult, error) in
                guard let strongSelf = self else { return }
                guard authResult != nil else {
                    print(error!)
                    return
                }
                
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, username: username, email: email), completion: { success in
                    if success {
                        UserDefaults.standard.set(email, forKey: "email")
                        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                        print("success!")
                    } else {
                        print("error")
                    }
                })
                strongSelf.performSegue(withIdentifier: "signUpToChats", sender: strongSelf)
            }
        }
    }
}
