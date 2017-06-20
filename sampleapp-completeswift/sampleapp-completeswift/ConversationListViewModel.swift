//
//  ConversationListViewModel.swift
//  Axiata
//
//  Created by Nitigron Ruengmontre on 12/7/2559 BE.
//  Copyright © 2559 Appsynth. All rights reserved.
//

import Foundation
import Applozic

extension ALMessage: ChatViewModelProtocol {

    private var alContact: ALContact? {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.to) else {
            return nil
        }
        return alContact
    }

    private var alChannel: ALChannel? {
        let alChannelService = ALChannelService()

        // TODO:  This is a workaround as other method uses closure.
        // Later replace this with:
        // alChannelService.getChannelInformation(, orClientChannelKey: , withCompletion: )
        guard let alChannel = alChannelService.getChannelByKey(self.groupId) else {
            return nil
        }
        return alChannel
    }

    var avatar: URL? {
        guard let alContact = alContact, let url = alContact.contactImageUrl else {
            return nil
        }
        return URL(string: url)
    }

    var avatarImage: UIImage? {
        return isGroupChat ? UIImage(named: "group_profile_picture-1") : nil
    }

    var avatarGroupImageUrl: String? {

        guard let alChannel = alChannel, let avatar = alChannel.channelImageURL else {
            return nil
        }
        return avatar
    }

    var name: String {
        guard let alContact = alContact, let displayName = alContact.displayName, !displayName.isEmpty else {
            return "No Name"
        }
        return displayName
    }

    var groupName: String {
        if isGroupChat {
            guard let alChannel = alChannel, let name = alChannel.name else {
                return ""
            }
            return name
        }
        return ""
    }

    var theLastMessage: String? {
        switch messageType {
        case .text:
            return message
        case .photo:
            return "Sent a photo"
        case .location:
            return "Sent a location"
        case .voice:
            return "Audio"
        case .information:
            return "Update"
        }
    }

    var hasUnreadMessages: Bool {
        if isGroupChat {
            guard let alChannel = alChannel, let unreadCount = alChannel.unreadCount else {
                return false
            }
            return unreadCount.boolValue
        } else {
            guard let alContact = alContact, let unreadCount = alContact.unreadCount else {
                return false
            }
            return unreadCount.boolValue
        }
    }

    var identifier: String {
        guard let key = self.key else {
            return ""
        }
        return key
    }

    var friendIdentifier: String? {
        return nil
    }

    var totalNumberOfUnreadMessages: UInt {
        if isGroupChat {
            guard let alChannel = alChannel, let unreadCount = alChannel.unreadCount else {
                return 0
            }
            return UInt(unreadCount)
        } else {
            guard let alContact = alContact, let unreadCount = alContact.unreadCount else {
                return 0
            }
            return UInt(unreadCount)
        }

    }

    var isGroupChat: Bool {
        guard let _ = self.groupId else {
            return false
        }
        return true
    }

    var contactId: String? {
        return self.contactIds
    }

    var channelKey: NSNumber? {
        return self.groupId
    }

}

protocol ConversationListViewModelDelegate: class {

    func listUpdated()
}


final class ConversationListViewModel: NSObject {

    weak var delegate: ConversationListViewModelDelegate?

    fileprivate var allMessages = [Any]()

    func prepareController(dbService: ALMessageDBService) {
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

    func remove(message: ALMessage) {
        let messageToDelete = allMessages.filter { ($0 as? ALMessage) == message }
        guard let messageDel = messageToDelete.first as? ALMessage,
            let index = (allMessages as? [ALMessage])?.index(of: messageDel) else {
                return
        }
        allMessages.remove(at: index)
    }

    func updateTypingStatus(in viewController: ConversationViewController, userId: String, status: Bool) {
        let contactDbService = ALContactDBService()
        let contact = contactDbService.loadContact(byKey: "userId", value: userId)
        guard let alContact = contact else { return }
        guard !alContact.block || !alContact.blockBy else { return }

        viewController.showTypingLabel(status: status, userId: userId)
    }

    func updateMessageList(messages: [Any]) {
        allMessages = messages
        delegate?.listUpdated()
    }

    func updateDeliveryReport(convVC: ConversationViewController?, messageKey: String?, contactId: String?, status: Int32?) {
        guard let vc = convVC  else { return }
        vc.updateDeliveryReport(messageKey: messageKey, contactId: contactId, status: status)
    }

    func updateStatusReport(convVC: ConversationViewController?, forContact contact: String?, status: Int32?) {
        guard let vc = convVC  else { return }
        vc.updateStatusReport(contactId: contact, status: status)
    }

    func addMessages(messages: Any) {
        guard let alMessages = messages as? [ALMessage], var allMessages = allMessages as? [ALMessage] else {
            return
        }

        for currentMessage in alMessages {
            var messagePresent = [ALMessage]()
            if let _ = currentMessage.groupId {
                messagePresent = allMessages.filter { ($0.groupId != nil) ? $0.groupId == currentMessage.groupId:false }
            } else {
                messagePresent = allMessages.filter { ($0.contactId != nil) ? $0.contactId == currentMessage.contactId:false }
            }

            if let firstElement = messagePresent.first, let index = allMessages.index(of: firstElement)  {
                allMessages[index] = currentMessage
                self.allMessages[index] = currentMessage
            } else {
                self.allMessages.append(currentMessage)
            }
        }
        if self.allMessages.count > 1 {

            self.allMessages = allMessages.sorted { ($0.createdAtTime != nil && $1.createdAtTime != nil) ? Int($0.createdAtTime) > Int($1.createdAtTime):false }
        }
        delegate?.listUpdated()
        
    }
}
