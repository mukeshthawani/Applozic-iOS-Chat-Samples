//
//  ALMessagesViewModel.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Applozic

extension ALMessage: ChatViewModelProtocol {
    
    var avatar: URL? {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.to), let url = alContact.contactImageUrl else {
            return nil
        }
        return URL(string: url)
    }
    
    var avatarImage: UIImage? {
        return nil
    }
    
    var avatarGroupImageUrl: String? {
        return nil
    }
        
    var name: String {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.to) else {
            return ""
        }
        return alContact.displayName
    }
    
    var theLastMessage: String? {
        return self.message
    }
    
    var hasUnreadMessages: Bool {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.to) else {
            return false
        }
        return alContact.unreadCount.boolValue
    }
    
    var identifier: Int {
        return self.messageId
    }
    
    var friendIdentifier: String? {
        return nil
    }
    
    var totalNumberOfUnreadMessages: UInt {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.to) else {
            return 0
        }
        return UInt(alContact.unreadCount)
    }
    
    var isGroupChat: Bool {
        return false
    }
    
    var contactId: String {
        return self.contactIds
    }
}

final class ALMessagesViewModel: NSObject {
    
    private var dbService: ALMessageDBService!
    private var alMqttConversationService: ALMQTTConversationService!
    
    fileprivate var allMessages = [Any]()
    
    func prepareController() {
        dbService = ALMessageDBService()
        dbService.delegate = self 
        dbService.getMessages(nil)
        alMqttConversationService = ALMQTTConversationService()
        alMqttConversationService.mqttConversationDelegate = self
    }
    
    func getChatList() -> [Any] {
        return allMessages
    }
    
    func numberOfSection() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return allMessages.count
    }
    
    func chatForRow(indexPath: IndexPath) -> ChatViewModelProtocol? {
        guard indexPath.row < allMessages.count else {
            return nil
        }
        
        guard let alMessage = allMessages[indexPath.row] as? ALMessage else {
            return nil
        }
        
        return alMessage
    }
}

extension ALMessagesViewModel: ALMessagesDelegate {
    func getMessagesArray(_ messagesArray: NSMutableArray!) {
        print("message array: ", messagesArray)
        let almessage = messagesArray.firstObject as! ALMessage
        print("almesg: ", almessage.message)
        guard let messages = messagesArray as? [Any] else {
            return
        }
        allMessages = messages
    }
    
    func updateMessageList(_ messagesArray: NSMutableArray!) {
        print("updated message array: ", messagesArray)
    }
}

extension ALMessagesViewModel: ALMQTTConversationDelegate {
    func syncCall(_ alMessage: ALMessage!, andMessageList messageArray: NSMutableArray!) {
        
    }
    
    func delivered(_ messageKey: String!, contactId: String!, withStatus status: Int32) {
        
    }
    
    func updateStatus(forContact contactId: String!, withStatus status: Int32) {
        
    }
    
    func updateTypingStatus(_ applicationKey: String!, userId: String!, status: Bool) {
        
    }
    
    func updateLastSeen(atStatus alUserDetail: ALUserDetail!) {
        
    }
    
    func mqttConnectionClosed() {
        
    }
}
