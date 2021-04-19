//
//  Message.swift
//  Messenger
//
//  Created by Vitaliy Yefimchuk on 16.04.2021.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
