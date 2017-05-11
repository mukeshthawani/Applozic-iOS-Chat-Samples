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
}

class ALConversationViewModel {
    
    let contactId: String
    weak var delegate: ALConversationViewModelDelegate?
    let maxWidth = UIScreen.main.bounds.width
    
    fileprivate var alMessageWrapper = ALMessageArrayWrapper()
    var messageModels = [MessageModel]()
    
    init(contactId: String) {
        self.contactId = contactId
    }
    
    func prepareController() {
        loadMessages()
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
            self.alMessageWrapper.addObject(toMessageArray: messages)
            let models = messages.map { ($0 as! ALMessage).messageModel }
            self.messageModels = models.reversed()
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
    
    private func addToWrapper(message: ALMessage) {
        self.alMessageWrapper.getUpdatedMessageArray().add(message)
        messageModels.append(message.messageModel)
    }
    
}
