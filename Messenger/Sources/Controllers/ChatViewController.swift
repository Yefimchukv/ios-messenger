//
//  ChatViewController.swift
//  Messenger
//
//  Created by Vitaliy Yefimchuk on 16.04.2021.
//

import UIKit
import MessageKit


class ChatViewController: MessagesViewController {
    
    var messages = [Message]()
    
    var selfSender = Sender(senderId: "1", displayName: "Yukinai")
    var otherSender = Sender(senderId: "2", displayName: "Yefimchukv")
    var testSender = Sender(senderId: "3", displayName: "Test")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Yukinai"
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hasdello")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Notafdsfhello")))
        messages.append(Message(sender: otherSender, messageId: "2", sentDate: Date(), kind: .text("Nothellsdfo")))
        messages.append(Message(sender: testSender, messageId: "3", sentDate: Date(), kind: .text("durumsubaba")))
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController: MessagesLayoutDelegate,
                               MessagesDataSource,
                               MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
