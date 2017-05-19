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
    func newMessagesAdded()
}

class ALConversationViewModel: NSObject {
    
    let contactId: String
    weak var delegate: ALConversationViewModelDelegate?
    let maxWidth = UIScreen.main.bounds.width
    let isGroup = false
    var individualLaunch = false
    
    var alMessageWrapper = ALMessageArrayWrapper()
    var messageModels = [MessageModel]()
    private var alMessages = NSMutableArray()
    
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
            var height: CGFloat =  0
            if messageModel.isMyMessage {
                height = VoiceCell.rowHeigh(viewModel: messageModel, width: maxWidth)
            } else {
                height = FriendVoiceCell.rowHeigh(viewModel: messageModel, width: maxWidth)
            }
            return height
            
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
    
    func getAudioData(for indexPath: IndexPath, completion: @escaping (Data?)->()) {
        if let alMessage = alMessages[indexPath.row] as? ALMessage {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            DownloadManager.shared.downloadAndSaveAudio(message: alMessage) {
                path in
                guard let path = path else {
                    return
                }
                self.updateDbMessageWith(key: "key", value: alMessage.key, filePath: path)
                alMessage.imageFilePath = path
                
                if let data = NSData(contentsOfFile: (documentsURL.appendingPathComponent(path)).path) as Data?     {
                    completion(data)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    /// Received from notification
    func addMessagesToList(_ messageList: [Any]) {
        guard let messages = messageList as? [ALMessage] else { return }
        let filteredArray  = messages.filter { $0.groupId == 0 || $0.groupId == nil && $0.contactId == self.contactId }
        let sortedArray = filteredArray.sorted { Int($0.createdAtTime) < Int($1.createdAtTime) }
        guard !sortedArray.isEmpty else { return }
//        for msg in sortedArray {
//            if !alMessageWrapper.getUpdatedMessageArray().contains(msg) {
//                print("not present")
//            }
//        }
        sortedArray.map { self.alMessageWrapper.addALMessage(toMessageArray: $0) }
        let models = sortedArray.map { $0.messageModel }
        messageModels.append(contentsOf: models)
        print("new messages: ", models.map { $0.message })
        delegate?.newMessagesAdded()
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
    
    func send(photo: UIImage) {
        print("image is:  ", photo)
        let filePath = ALImagePickerHandler.saveImage(toDocDirectory: photo)
        print("filepath:: ", filePath)
        guard let path = filePath, let url = URL(string: path) else { return }
        processAttachment(filePath: url, text: "", contentType: Int(ALMESSAGE_CONTENT_ATTACHMENT))
        
    }
    
    func send(voiceMessage: Data) {
        print("voice data received: ", voiceMessage.count)
        let fileName = String(format: "AUD-%f.m4a", Date().timeIntervalSince1970*1000)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fullPath = documentsURL.appendingPathComponent(fileName)
        do {
            try voiceMessage.write(to: fullPath, options: .atomic)
        } catch {
            NSLog("error when saving the voice message")
        }
        processAttachment(filePath: fullPath, text: "", contentType: Int(ALMESSAGE_CONTENT_AUDIO))
        
    }
    
    func updateMessageModelAt(indexPath: IndexPath, data: Data) {
        var message = messageForRow(indexPath: indexPath)
        message?.voiceData = data
        messageModels[indexPath.row] = message as! MessageModel
        delegate?.messageUpdated()
    }
    
    private func updateDbMessageWith(key: String, value: String, filePath: String) {
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
    
    private func getMessageToPost() -> ALMessage {
        let messageModel = messageModels.first
        let alMessage = ALMessage()
        alMessage.to = messageModel?.contactId
        alMessage.contactIds = messageModel?.contactId
        alMessage.message = ""
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
        return  alMessage
    }
    
    private func getFileMetaInfo() -> ALFileMetaInfo {
        let info = ALFileMetaInfo()
        info.blobKey = nil
        info.contentType = ""
        info.createdAtTime = nil
        info.key = nil
        info.name = ""
        info.size = ""
        info.userKey = ""
        info.thumbnailUrl = ""
        info.progressValue = 0
        return info
    }
    
    private func processAttachment(filePath: URL, text: String, contentType: Int) {
        var alMessage = getMessageToPost()
        alMessage.contentType = Int16(contentType)
        alMessage.fileMeta = getFileMetaInfo()
        alMessage.imageFilePath = filePath.lastPathComponent
        alMessage.fileMeta.name = String(format: "%@-5-%@", self.contactId, filePath.lastPathComponent)
        let pathExtension = filePath.pathExtension
        let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue()
        let mimetype = (UTTypeCopyPreferredTagWithClass(uti!, kUTTagClassMIMEType)?.takeRetainedValue()) as! String
        alMessage.fileMeta.contentType = String(describing: mimetype)
        
        let imageSize = NSData(contentsOfFile: filePath.path)
        alMessage.fileMeta.size = String(format: "%lu", (imageSize?.length)!)
        alMessageWrapper.addALMessage(toMessageArray: alMessage)
        
        let dbHandler = ALDBHandler.sharedInstance()
        let messageService = ALMessageDBService()
        let messageEntity = messageService.createMessageEntityForDBInsertion(with: alMessage)
        do {
            try dbHandler?.managedObjectContext.save()
        } catch {
            NSLog("Not saved due to error")
        }
        alMessage.msgDBObjectId = messageEntity?.objectID
        addToWrapper(message: alMessage)
        delegate?.messageUpdated()
        uploadImage(alMessage: alMessage, indexPath: IndexPath(row: messageModels.count-1, section: 0))
    }
    
    private func uploadImage(alMessage: ALMessage, indexPath: IndexPath)  {
        let clientService = ALMessageClientService()
        let messageService = ALMessageDBService()
        let alHandler = ALDBHandler.sharedInstance()
        var dbMessage: DB_Message?
        do {
            dbMessage = try messageService.getMeesageBy(alMessage.msgDBObjectId) as? DB_Message
        } catch {
            
        }
        dbMessage?.inProgress = 1
        dbMessage?.isUploadFailed = 0
        do {
            try alHandler?.managedObjectContext.save()
        } catch {
            
        }
        print("content type: ", alMessage.fileMeta.contentType)
        print("file path: ", alMessage.imageFilePath)
        clientService.sendPhoto(forUserInfo: alMessage.dictionary(), withCompletion: {
            url, error in
            guard error == nil, let urlStr = url else { return }
            DownloadManager.shared.uploadImage(message: alMessage, databaseObj: (dbMessage?.fileMetaInfo)!, uploadURL: urlStr) {
                response in
                guard let fileInfo = response as? [String: Any], let fileMeta = fileInfo["fileMeta"] as? [String: Any] else { return }
                let message = messageService.createMessageEntity(dbMessage)
                message?.fileMeta.populate(fileMeta)
                message?.status = NSNumber(integerLiteral: Int(SENT.rawValue))
                do {
                    try alHandler?.managedObjectContext.save()
                } catch {
                    NSLog("Not saved due to error")
                }
                
                self.send(message: message!) {
                    success in
                    guard success else { return }
                    DispatchQueue.main.async {
                        print("UI updated at row: ", indexPath.row, message?.isSent)
                        self.messageModels[indexPath.row] = (message?.messageModel)!
                        self.delegate?.updateMessageAt(indexPath: indexPath)
                    }
                }
                
            }
        })
    }
    
    private func send(message: ALMessage, completion: @escaping (Bool)->()) {
        ALMessageService.sendMessages(message, withCompletion: {
            message, error in
            NSLog("Message sent: \(message), \(error)")
            if error == nil {
                NSLog("No errors while sending the message")
                completion(true)
            }
            else {
                completion(false)
            }
            
        })
    }
}
