//
//  ChatAppUser.swift
//  Messenger
//
//  Created by Виталий Ефимчук on 14.04.2021.
//

import Foundation

struct ChatAppUser {
    //let profilePictureURL: URL
    let firstName: String
    let lastName: String
    let username: String
    let email: String
    
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
