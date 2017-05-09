//
//  ALMessage+Extension.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 08/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Applozic

let friendsMessage = "4"
let myMessage = "5"

extension ALMessage {
    
    var isMyMessage: Bool {
        return self.type == friendsMessage
    }
    
    func rowHeight(cellFrame frame: CGRect) -> CGFloat {
        let height = ALUIConstant.getCellHeight(self, andCellFrame: frame)
        return height
    }
    
    var date: Date {
        let sentAt = Date(timeIntervalSince1970: Double(self.createdAtTime))
        return sentAt
    }
    
    var time: String? {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm"
        return dateFormatterGet.string(from: date)
    }

}

extension ALMessage {
    
    var messageModel: MessageModel {
        let messageModel = MessageModel()
        messageModel.message = message
        messageModel.isMyMessage = isMyMessage
        messageModel.date = date
        messageModel.time = time
        messageModel.avatarURL = avatar
        messageModel.displayName = name
        messageModel.contactId = contactId
        return messageModel
    }
}
