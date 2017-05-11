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

let imageBaseUrl = ALUserDefaultsHandler.getFILEURL() + "/rest/ws/aws/file/"

extension ALMessage {
    
    var isMyMessage: Bool {
        return self.type == myMessage
    }
    
    var messageType: MessageType {
        if contentType == Int16(ALMESSAGE_CONTENT_DEFAULT) {
            return .text
        } else if contentType == Int16(ALMESSAGE_CONTENT_LOCATION) {
            return .location
        } else if let fileMeta = fileMeta {
            if fileMeta.contentType.hasPrefix("image") {
                return .photo
            } else if fileMeta.contentType.hasPrefix("audio") {
                return .voice
            }
        }
        return .text
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
    
    var isSent: Bool {
        guard let status = status else {
            return false
        }
        return status == NSNumber(integerLiteral: Int(SENT.rawValue))
    }
    
    var isAllRead: Bool {
        guard let status = status else {
            return false
        }
        return status == NSNumber(integerLiteral: Int(DELIVERED_AND_READ.rawValue))
    }
    
    var isAllReceived: Bool {
        guard let status = status else {
            return false
        }
        return status == NSNumber(integerLiteral: Int(DELIVERED.rawValue))
    }
    
    var ratio: CGFloat {
        // Using default
        return 0.9
    }
    
    var size: Int64 {
        guard let fileMeta = fileMeta, let size = Int64(fileMeta.getTheSize()) else {
            return 0
        }
        return size
    }
    
    var thumbnailURL: URL? {
        guard let fileMeta = fileMeta, let urlStr = fileMeta.thumbnailUrl, let url = URL(string: urlStr)  else {
            return nil
        }
        return url
    }
    
    var imageUrl: URL? {
        guard let fileMeta = fileMeta, let urlStr = fileMeta.blobKey, let imageUrl = URL(string: imageBaseUrl + urlStr) else {
            return nil
        }
        print("imageUrl: ", imageUrl)
        return imageUrl
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
        messageModel.conversationId = conversationId
        messageModel.groupId = groupId
        messageModel.isSent = isSent
        messageModel.isAllReceived = isAllReceived
        messageModel.isAllRead = isAllRead
        messageModel.messageType = messageType
        messageModel.ratio = ratio
        messageModel.size = size
        messageModel.thumbnailURL = thumbnailURL
        messageModel.imageURL = imageUrl
        return messageModel
    }
}
