//
//  ALPushNotificationHandler.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 18/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Applozic

class ALPushNotificationHandler {
    static let shared = ALPushNotificationHandler()
    var navVC: UINavigationController?

    var contactId: String?
    var groupId: NSNumber?
    var title: String = ""


    private var alContact: ALContact? {
        let alContactDbService = ALContactDBService()
        guard let alContact = alContactDbService.loadContact(byKey: "userId", value: self.contactId) else {
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

    func dataConnectionNotificationHandler() {

        // No need to add removeObserver() as it is present in pushAssist.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "showNotificationAndLaunchChat"), object: nil, queue: nil, using: {[weak self] notification in
            print("launch chat push notification received")

            //Todo: Handle group

            guard let weakSelf = self, let object = notification.object as? String else { return }
            let components = object.components(separatedBy: ":")
            if components.count > 1 {
                let id = NSNumber(integerLiteral: Int(components[1])!)
                weakSelf.groupId = id
                guard let alChannel = weakSelf.alChannel, let name = alChannel.name else { return }
                weakSelf.title = name

            } else {
                weakSelf.contactId = object
                guard let alContact = weakSelf.alContact, let displayName = alContact.displayName else { return }
                weakSelf.title = displayName
            }

            //            weakSelf.launchIndividualChatWith(userId: contactId)
        })
    }


        func launchIndividualChatWith(userId: String) {
            print("Called via notification and user id is: ", userId)
    
            let messagesVC = ConversationListViewController()
            messagesVC.contactId = userId
            let rootVC =  UIApplication.shared.keyWindow?.rootViewController
            navVC = UINavigationController(rootViewController: messagesVC)
            navVC?.modalTransitionStyle = .crossDissolve
            rootVC?.present(navVC!, animated: true, completion: nil)
        }
}
