//
//  Chat.swift
//  Messenger
//
//  Created by Vitaliy Yefimchuk on 22.04.2021.
//

import Foundation

struct Chat: Codable {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage: Codable {
    let date: String
    let text: String
    let isRead: Bool
}
