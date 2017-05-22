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
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.to), let displayName = alContact.displayName else {
            return ""
        }
        return displayName
    }
    
    var theLastMessage: String? {
        return self.message
    }
    
    var hasUnreadMessages: Bool {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.to), let unreadCount = alContact.unreadCount else {
            return false
        }
        return unreadCount.boolValue
    }
    
    var identifier: String {
        return self.key
    }
    
    var friendIdentifier: String? {
        return nil
    }
    
    var totalNumberOfUnreadMessages: UInt {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.to), let unreadCount = alContact.unreadCount else {
            return 0
        }
        return UInt(unreadCount)
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
    
    fileprivate var allMessages = [Any]()
    
    func prepareController() {
        dbService = ALMessageDBService()
        dbService.delegate = self 
        dbService.getMessages(nil)
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
    
    func updateTypingStatus(in viewController: ALConversationViewController, userId: String, status: Bool) {
        let contactDbService = ALContactDBService()
        let contact = contactDbService.loadContact(byKey: "userId", value: userId)
        guard let alContact = contact else { return }
        guard !alContact.block || !alContact.blockBy else { return }
        
        viewController.showTypingLabel(status: status, userId: userId)
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
