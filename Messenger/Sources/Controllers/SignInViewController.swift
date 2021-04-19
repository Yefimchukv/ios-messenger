//
//  SignInViewController.swift
//  Messenger
//
//  Created by Виталий Ефимчук on 11.04.2021.
//

import UIKit
import AuthenticationServices
import FirebaseAuth

import CryptoKit

class SignInViewController: UIViewController {
    @IBOutlet weak var emailOrUserNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loadingBar: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Email/password Sign In
    
    @IBAction func enteringAccountFinished(_ sender: UITextField) {
        loadingBar.startAnimating()
        guard let email = emailOrUserNameTextField.text,
              let password = passwordTextField.text else {
            print("Failed to Log In, check your data")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authDataResult, error) in
            guard let result = authDataResult, error == nil else {
                print(error!)
                return
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            
            print("Logged In as: \(result.user)")
            self?.loadingBar.stopAnimating()
            self?.performSegue(withIdentifier: "signInToChats", sender: self)
            
        }
    }
    
    
    // MARK: - Apple Sign In Authorization
    @IBAction func appleSignInTapped(_ sender: ASAuthorizationAppleIDButton) {
        performSignIn()
    }
    
    func performSignIn() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            var textField = UITextField()
            
            let alert = UIAlertController(title: "Enter Your Username", message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Enter", style: .default) { (action) in
                
                guard let aFirstName = appleIDCredential.fullName?.givenName,
                      let aLastName = appleIDCredential.fullName?.familyName,
                      let aEmail = appleIDCredential.email,
                      let aUsername = textField.text else {
                    print("Can't access the data")
                    return
                }
                
                DatabaseManager.shared.userExists(with: aEmail) { exists in
                    guard !exists else {
                        print("User already exists")
                        return
                    }
                    let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
                    print(credential)
                    
                    Auth.auth().signIn(with: credential) { [weak self] (authDataResult, error) in
                        guard let self = self else { return }
                        
                        if let user = authDataResult?.user {
                            print("Nice! You're now signed in as \(user.uid), email: \(user.email ?? "Unknown")")
                            DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: aFirstName, lastName: aLastName, username: aUsername, email: aEmail), completion: { success in
                                if success {
                                    print("success!")
                                } else {
                                    print("error")
                                }
                            })
                            
                            self.performSegue(withIdentifier: "signInToChats", sender: self)
                            
                        } else {
                            print("Error at the end of the signing in: \(error!.localizedDescription)")
                            return
                        }
                    }
                }
                
            }
            
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Enter Your Username"
                textField = alertTextField
            }
            
            alert.addAction(action)
            
            present(alert, animated: true, completion: nil)
        }
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: - SHA256 nonce generator
private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}

// Unhashed nonce.
fileprivate var currentNonce: String?

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    
    return hashString
}
