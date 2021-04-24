//
//  ChatViewController.swift
//  Messenger
//
//  Created by Vitaliy Yefimchuk on 16.04.2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView


class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewChat = false
    public let otherUserEmail: String
    private let chatId : String?
    
    var messages = [Message]()

    var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        return Sender(senderId: safeEmail, displayName: "Me")
    }
    
    init(with email: String, id: String?) {
        self.chatId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        if let chatId = chatId {
            listenForMessages(id: chatId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = self
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func listenForMessages(id: String) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print(messages)
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
        }
        print(text)
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        
        //Send Message
        if isNewChat {
            //create convo in DB
            
            DatabaseManager.shared.createNewChat(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
                guard let self = self else { return }
                if success {
                    print("message sent")
                    self.isNewChat = false
                }
                else {
                    
                    print("failsed to send")
                }
            })
        }
        else {
            guard let chatId = chatId,
                  let name = self.title else {
                return
            }
            //apped to existing convo data
            DatabaseManager.shared.sendMessage(to: chatId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { success in
                if success {
                    print("message sent")
                }
                else {
                    
                    print("failsed to send")
                }
            })
        }
    }
    private func createMessageId() -> String? {
        //date, otherUserEmail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let safeOtherUserEmail = DatabaseManager.safeEmail(emailAddress: otherUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(safeOtherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("created ID: \(newIdentifier)")
        
        return newIdentifier
    }
 }

extension ChatViewController: MessagesLayoutDelegate,
                               MessagesDataSource,
                               MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, email shoud be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
