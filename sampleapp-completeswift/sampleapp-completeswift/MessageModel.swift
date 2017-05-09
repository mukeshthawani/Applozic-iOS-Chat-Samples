//
//  MessageModel.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 08/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

class MessageModel: MessageViewModel {
    
    var message: String? = ""
    var isMyMessage: Bool = false
    var date: Date = Date()
    var time: String?
    var avatarURL: URL?
    var displayName: String?
    var contactId: String = ""
}
