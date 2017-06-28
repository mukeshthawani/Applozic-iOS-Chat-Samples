//
//  ALMessage+Extension.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Applozic
import ObjectMapper

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
        } else if contentType == Int16(ALMESSAGE_CHANNEL_NOTIFICATION) {
            return .information
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
        let sentAt = Date(timeIntervalSince1970: Double(self.createdAtTime.doubleValue/1000))
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
        if messageType == .text {
            return 1.7
        }
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
        return imageUrl
    }

    var filePath: String? {
        guard let filePath = imageFilePath else {
            return nil
        }
        return filePath
    }

    var geocode: Geocode? {
        guard messageType == .location else {
            return nil
        }
        if let message = message {
            let jsonObject = try! JSONSerialization.jsonObject(with: message.data(using: .utf8)!, options: .mutableContainers) as! [String: Any]
            guard let latString = jsonObject["lat"] as? String,
                let lonString = jsonObject["lon"] as? String,let lat = Double(latString), let lon = Double(lonString) else {
                    return nil
            }
            return Geocode(JSON: ["lat": lat, "lon": lon])
        }
        return nil
    }

}

extension ALMessage {

    var messageModel: MessageModel {
        let messageModel = MessageModel()
        messageModel.message = message
        messageModel.isMyMessage = isMyMessage
        messageModel.identifier = identifier
        messageModel.date = date
        messageModel.time = time
        messageModel.avatarURL = avatar
        messageModel.displayName = name
        messageModel.contactId = contactId
        messageModel.conversationId = conversationId
        messageModel.channelKey = channelKey
        messageModel.isSent = isSent
        messageModel.isAllReceived = isAllReceived
        messageModel.isAllRead = isAllRead
        messageModel.messageType = messageType
        messageModel.ratio = ratio
        messageModel.size = size
        messageModel.thumbnailURL = thumbnailURL
        messageModel.imageURL = imageUrl
        messageModel.filePath = filePath
        messageModel.geocode = geocode
        return messageModel
    }
}

extension ALMessage {
    override open func isEqual(_ object: Any?) -> Bool {
        if let object = object as? ALMessage, let objectKey = object.key, let key = self.key {
            return key == objectKey
        } else {
            return false
        }
    }
}
