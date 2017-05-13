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
    var messageType: MessageType = .text
    var identifier: String = ""
    var date: Date = Date()
    var time: String?
    var avatarURL: URL?
    var displayName: String?
    var contactId: String = ""
    var conversationId: NSNumber?
    var groupId: NSNumber?
    var isSent: Bool = false
    var isAllReceived: Bool = false
    var isAllRead: Bool = false
    var ratio: CGFloat = 0.0
    var size: Int64 = 0
    var thumbnailURL: URL?
    var imageURL: URL?
    var filePath: String?
    var voiceTotalDuration: CGFloat = 0
    var voiceCurrentDuration: CGFloat = 0
    var voiceCurrentState: VoiceCellState = .stop
    var voiceData: Data?
}

