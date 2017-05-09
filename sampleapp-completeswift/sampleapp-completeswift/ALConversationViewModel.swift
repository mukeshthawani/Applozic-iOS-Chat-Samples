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
}

class ALConversationViewModel {
    
    let contactId: String
    weak var delegate: ALConversationViewModelDelegate?
    
    fileprivate var alMessageWrapper = ALMessageArrayWrapper()
    fileprivate var messageModels = [MessageModel]()
    
    init(contactId: String) {
        self.contactId = contactId
    }
    
    func prepareController() {
        loadMessages()
    }
    
    func loadMessages() {
        let messageListRequest = MessageListRequest()
        messageListRequest.userId = contactId
        messageListRequest.endTimeStamp = nil
        ALMessageService.getMessageList(forUser: messageListRequest, withCompletion: {
            messages, error, userDetail in
            print("messages for user: ", messages)
            guard error == nil, let messages = messages else {
                self.delegate?.loadingFinished(error: error)
                return
            }
            self.alMessageWrapper.addObject(toMessageArray: messages)
            self.messageModels = messages.map { ($0 as! ALMessage).messageModel }
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
        let message = alMessageWrapper.getUpdatedMessageArray()[indexPath.row] as? ALMessage
        let height = ALUIConstant.getCellHeight(message, andCellFrame: cellFrame)
        return height
    }
    
    func nextPage() {
        let contactId = messageModels.first?.contactId
        guard ALUserDefaultsHandler.isShowLoadEarlierOption(contactId) && ALUserDefaultsHandler.isServerCallDone(forMSGList: contactId) else {
            return
        }
        loadMessages()
    }
    
}
