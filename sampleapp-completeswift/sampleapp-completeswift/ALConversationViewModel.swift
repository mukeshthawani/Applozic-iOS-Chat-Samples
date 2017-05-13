//
//  ALConversationViewModel.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 05/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Applozic


protocol ALConversationViewModelDelegate: class {
    func loadingFinished(error: Error?)
    func messageUpdated()
    func updateMessageAt(indexPath: IndexPath)
}

class ALConversationViewModel {
    
    let contactId: String
    weak var delegate: ALConversationViewModelDelegate?
    let maxWidth = UIScreen.main.bounds.width
    let isGroup = false
    
    fileprivate var alMessageWrapper = ALMessageArrayWrapper()
    var messageModels = [MessageModel]()
    var alMessages = NSMutableArray()
    
    init(contactId: String) {
        self.contactId = contactId
    }
    
    func prepareController() {
        if ALUserDefaultsHandler.isServerCallDone(forMSGList: contactId) {
            loadMessagesFromDB()
        } else {
            loadMessages()
        }
        
    }
    
    func loadMessages() {
        
        var time: NSNumber? = nil
        if let messageList = alMessageWrapper.getUpdatedMessageArray(), messageList.count > 1 {
            time = (messageList.firstObject as! ALMessage).createdAtTime
        }
        
        let messageListRequest = MessageListRequest()
        messageListRequest.userId = contactId
        messageListRequest.endTimeStamp = time
        ALMessageService.getMessageList(forUser: messageListRequest, withCompletion: {
            messages, error, userDetail in
            guard error == nil, let messages = messages else {
                self.delegate?.loadingFinished(error: error)
                return
            }
            NSLog("messages loaded: ", messages)
            self.alMessages = messages.reversed() as! NSMutableArray
//            print("all file paths: ", messages.map { ($0 as! ALMessage).imageFilePath })
            self.alMessageWrapper.addObject(toMessageArray: self.alMessages)
            let models = self.alMessages.map { ($0 as! ALMessage).messageModel }
            self.messageModels = models
            if self.messageModels.count < 50 {
                ALUserDefaultsHandler.setShowLoadEarlierOption(false, forContactId: self.messageModels.first?.contactId)
            }
            self.delegate?.loadingFinished(error: nil)
        })
    }
    
    func loadMessagesFromDB() {
        ALMessageService.getMessageList(forContactId: contactId, isGroup: isGroup, channelKey: nil, conversationId: nil, start: 0, withCompletion: {
            messages in
            guard let messages = messages else {
                self.delegate?.loadingFinished(error: nil)
                return
            }
            NSLog("messages loaded: ", messages)
            self.alMessages = messages
            self.alMessageWrapper.addObject(toMessageArray: messages)
            let models = messages.map { ($0 as! ALMessage).messageModel }
            self.messageModels = models
            if self.messageModels.count < 50 {
                ALUserDefaultsHandler.setShowLoadEarlierOption(false, forContactId: self.messageModels.first?.contactId)
            }
            self.delegate?.loadingFinished(error: nil)
        })
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows(section: Int) -> Int {
        guard section == 0 else { return 0 }
        return messageModels.count
    }
    
    func messageForRow(indexPath: IndexPath) -> MessageViewModel? {
        guard indexPath.row < messageModels.count else { return nil }
        return messageModels[indexPath.row]
    }
    
    func messageForRow(identifier: String) -> MessageViewModel? {
        guard let messageModel = messageModels.filter({$0.identifier == identifier}).first else {return nil}
        return messageModel
    }
    
    func heightForRow(indexPath: IndexPath, cellFrame: CGRect) -> CGFloat {
        let messageModel = messageModels[indexPath.row]
        switch messageModel.messageType {
        case .text:
            if messageModel.isMyMessage {
                
                let heigh = MyMessageCell.rowHeigh(viewModel: messageModel, width: maxWidth)
//                cache?.setDouble(value: Double(heigh), forKey: identifier)
                return heigh
                
            } else {
                
                let heigh = FriendMessageCell.rowHeigh(viewModel: messageModel, width: maxWidth)
//                cache?.setDouble(value: Double(heigh), forKey: identifier)
                return heigh
                
            }
        case .photo:
            if messageModel.isMyMessage {
                
                if messageModel.ratio < 1 {
                    
                    let heigh = MyPhotoPortalCell.rowHeigh(viewModel: messageModel, width: maxWidth)
//                    cache?.setDouble(value: Double(heigh), forKey: identifier)
                    return heigh
                    
                } else {
                    let heigh = MyPhotoLandscapeCell.rowHeigh(viewModel: messageModel, width: maxWidth)
//                    cache?.setDouble(value: Double(heigh), forKey: identifier)
                    return heigh
                }
                
                
            } else {
                
                if messageModel.ratio < 1 {
                    
                    let heigh = FriendPhotoPortalCell.rowHeigh(viewModel: messageModel, width: maxWidth)
//                    cache?.setDouble(value: Double(heigh), forKey: identifier)
                    return heigh
                    
                } else {
                    let heigh = FriendPhotoLandscapeCell.rowHeigh(viewModel: messageModel, width: maxWidth)
//                    cache?.setDouble(value: Double(heigh), forKey: identifier)
                    return heigh
                }
                
            }
        case .voice:
            return 100
        default:
            print("Not available")
            return 0
        }
    }
    
    func nextPage() {
        let contactId = messageModels.first?.contactId
        guard ALUserDefaultsHandler.isShowLoadEarlierOption(contactId) && ALUserDefaultsHandler.isServerCallDone(forMSGList: contactId) else {
            return
        }
        loadMessages()
    }
    
    func send(message: String) {
        let messageModel = messageModels.first
        let alMessage = ALMessage()
        alMessage.to = messageModel?.contactId
        alMessage.contactIds = messageModel?.contactId
        alMessage.message = message
        alMessage.type = "5"
        let date = Date().timeIntervalSince1970*1000
        alMessage.createdAtTime = NSNumber(value: date)
        alMessage.sendToDevice = false
        alMessage.deviceKey = ALUserDefaultsHandler.getDeviceKeyString()
        alMessage.shared = false
        alMessage.fileMeta = nil
        alMessage.storeOnDevice = false
        alMessage.contentType = Int16(ALMESSAGE_CONTENT_DEFAULT)
        alMessage.key = UUID().uuidString
        alMessage.source = Int16(SOURCE_IOS)
        alMessage.conversationId = messageModel?.conversationId
        alMessage.groupId = messageModel?.groupId
        
        addToWrapper(message: alMessage)
        
        ALMessageService.sendMessages(alMessage, withCompletion: {
            message, error in
            NSLog("Message sent: \(message), \(error)")
            guard error == nil else { return }
            NSLog("No errors while sending the message")
            alMessage.status = NSNumber(integerLiteral: Int(SENT.rawValue))
            self.messageModels[self.messageModels.count-1] = alMessage.messageModel
            self.delegate?.messageUpdated()
        })
    }
    
    func updateMessageModelAt(indexPath: IndexPath, data: Data) {
        var message = messageForRow(indexPath: indexPath)
        message?.voiceData = data
        messageModels[indexPath.row] = message as! MessageModel
        delegate?.updateMessageAt(indexPath: indexPath) 
    }
    
    func updateDbMessageWith(key: String, value: String, filePath: String) {
        let messageService = ALMessageDBService()
        let alHandler = ALDBHandler.sharedInstance()
        let dbMessage: DB_Message = messageService.getMessageByKey(key, value: value) as! DB_Message
        dbMessage.filePath = filePath
        do {
            try alHandler?.managedObjectContext.save()
        } catch {
            NSLog("Not saved due to error")
        }
    }

    private func addToWrapper(message: ALMessage) {
        self.alMessageWrapper.getUpdatedMessageArray().add(message)
        messageModels.append(message.messageModel)
    }
}
