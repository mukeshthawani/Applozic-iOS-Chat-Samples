//
//  ALConversationViewController.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 05/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

import MBProgressHUD
import Applozic
import Alamofire


final class ALConversationViewController: ALBaseViewController {
    
    var viewModel: ALConversationViewModel!
    private var isFirstTime = true
    private var bottomConstraint: NSLayoutConstraint?
    private var isJustSent: Bool = false
    let audioPlayer = AudioPlayer()
    
    let tableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
//        tv.separatorStyle   = .none
//        tv.allowsSelection  = false
//        tv.backgroundColor  = UIColor.white
//        tv.clipsToBounds    = true
        return tv
    }()
    
    fileprivate let titleButton : UIButton = {
        let titleButton = UIButton()
        titleButton.titleLabel?.textColor   = .white
        titleButton.titleLabel?.font        = UIFont.boldSystemFont(ofSize: 17.0)
        return titleButton
    }()
    
    let chatBar: ChatBar = ChatBar(frame: .zero)
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.delegate = self
        viewModel.prepareController()
        if self.isFirstTime {
            self.setupNavigation()
        } else {
            tableView.reloadData()
        }
        print("id: ", viewModel.messageModels.first?.contactId)
//        if ALUserDefaultsHandler.isServerCallDone(forMSGList: <#T##String!#>)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupView()
        isFirstTime = false
        
        //        viewModel.prepareController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection  = false
        tableView.clipsToBounds    = true
        ALUserDefaultsHandler.setDebugLogsRequire(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isFirstTime {
            self.tableView.scrollToBottomByOfset(animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAudioPlayer()
        chatBar.stopRecording()
    }

    
    func setupView() {
        view.backgroundColor = UIColor.white
        view.addViewsForAutolayout(views: [tableView, chatBar])
        
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        chatBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chatBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = chatBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint?.isActive = true
        prepareTable()
        prepareChatBar()

    }
    
    private func setupNavigation() {
        
        titleButton.setTitle(self.title, for: .normal)
//        titleButton.addTarget(self, action: #selector(showParticipantListChat), for: .touchUpInside)
        
        self.navigationItem.titleView = titleButton
    }
    
    private func prepareTable() {
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tableTapped(gesture:)))
        gesture.numberOfTapsRequired = 1
        tableView.addGestureRecognizer(gesture)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: 0.1))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: 8))
        
//        addStateOfConversation()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(MyMessageCell.self)
        tableView.register(FriendMessageCell.self)
        tableView.register(MyPhotoPortalCell.self)
        tableView.register(MyPhotoLandscapeCell.self)
        
        tableView.register(FriendPhotoPortalCell.self)
        tableView.register(FriendPhotoLandscapeCell.self)
        
        tableView.register(MyVoiceCell.self)
        tableView.register(FriendVoiceCell.self)
//
//        tableView.register(MyLocationCell.self)
//        tableView.register(FriendLocationCell.self)
//        
//        tableView.register(InformationCell.self)
    }
    
    func tableTapped(gesture: UITapGestureRecognizer) {
    }
    
    private func prepareChatBar() {
        chatBar.accessibilityIdentifier = "chatBar"
        chatBar.setComingSoonDelegate(delegate: self.view)
        chatBar.action = { [weak self] (action) in
            
            guard let weakSelf = self else {
                return
            }
            
//            if case .more(_) = action {
//                
//                if weakSelf.moreBar.isHidden == true {
//                    weakSelf.showMoreBar()
//                } else {
//                    weakSelf.hideMoreBar()
//                }
//                
//                return
//            }
//            
//            weakSelf.hideMoreBar()
            
            switch action {
                
            case .sendText(let button, let message):
                
                if message.characters.count < 1 {
                    return
                }
                
                button.isUserInteractionEnabled = false
//                    weakSelf.viewModel.sendKeyboardDoneTyping()
                    
                    weakSelf.isJustSent = true
                    
                    weakSelf.chatBar.clear()
                    
                    NSLog("Sent: ", message)
                    
                    weakSelf.viewModel.send(message: message)
                    button.isUserInteractionEnabled = true
            case .chatBarTextChange(_):
                
//                weakSelf.viewModel.sendKeyboardBeginTyping()
                
                UIView.animate(withDuration: 0.05, animations: { () in
                    weakSelf.view.layoutIfNeeded()
                }, completion: { [weak self] (_) in
                    
                    guard let weakSelf = self else {
                        return
                    }
                    
                    if weakSelf.tableView.isAtBottom == true && weakSelf.isJustSent == false {
                        weakSelf.tableView.scrollToBottomByOfset(animated: true)
                    }
                })
            case .sendPhoto(let button, let image):
                print("Image call done")
                    weakSelf.isJustSent = true
                    
                    weakSelf.viewModel.send(photo: image)
                    
                    button.isUserInteractionEnabled = true
                    button.isUserInteractionEnabled = true
                
            case .sendVoice(let voice):
                do {
                    try weakSelf.viewModel.send(voiceMessage: voice as Data)
                } catch {
                    weakSelf.view.makeToast(SystemMessage.Warning.PleaseTryAgain, duration: 1.0, position: .center)
                }
                break;
            default:
                print("Not available")
            }
        }
    }
    
}

extension ALConversationViewController: ALConversationViewModelDelegate {
    func loadingFinished(error: Error?) {
        tableView.reloadData()
        DispatchQueue.main.async {
            self.tableView.scrollToBottom()
        }
    }
    
    func messageUpdated() {
        tableView.reloadData()
    }
    
    func updateMessageAt(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension ALConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var message = viewModel.messageForRow(indexPath: indexPath) else {
            return UITableViewCell()
        }
        print("Cell updated at row: ", indexPath.row, "and type is: ", message.messageType)
        switch message.messageType {
        case .text:
            if message.isMyMessage {
                
                let cell: MyMessageCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.update(chatBar: self.chatBar)
                return cell
                
            } else {
                let cell: FriendMessageCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.update(chatBar: self.chatBar)
                return cell
            }
        case .photo:
            if message.isMyMessage {
                // Right now ratio is fixed to 1.77
                if message.ratio < 1 {
                    print("image messsage called")
                    let cell: MyPhotoPortalCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.update(viewModel: message)
                    return cell
                    
                } else {
                    let cell: MyPhotoLandscapeCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.update(viewModel: message)
                    return cell
                }
                
            } else {
                if message.ratio < 1 {
                    
                    let cell: FriendPhotoPortalCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.update(viewModel: message)
                    return cell
                    
                } else {
                    let cell: FriendPhotoLandscapeCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.update(viewModel: message)
                    return cell
                }
            }
        case .voice:
            print("voice cell loaded with url", message.filePath)
            print("current voice state: ", message.voiceCurrentState, "row", indexPath.row, message.voiceTotalDuration, message.voiceData)
            print("voice identifier: ", message.identifier, "and row: ", indexPath.row)
            if message.voiceData ==  nil {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                if let path = message.filePath, let data = NSData(contentsOfFile: (documentsURL.appendingPathComponent(path)).path) as Data? {
                    self.viewModel.updateMessageModelAt(indexPath: indexPath, data: data)
                } else {
                     viewModel.getAudioData(for: indexPath) { data in
                        guard let voiceData = data else { return }
                        self.viewModel.updateMessageModelAt(indexPath: indexPath, data: voiceData)
                    }
                }
            }
            
            if message.voiceTotalDuration == 0 {
                if let data = message.voiceData {
                    let voice = data as NSData
                    do {
                        let player = try AVAudioPlayer(data: voice as Data, fileTypeHint: AVFileTypeWAVE)
                        message.voiceTotalDuration = CGFloat(player.duration)
                    } catch let error as NSError {
//                        Logger.error(message: error)
                    }
                }
            }
            
            if message.isMyMessage {
                let cell: MyVoiceCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
//                cell.backgroundColor = UIColor.white
                cell.update(viewModel: message)
                cell.setCellDelegate(delegate: self)
                return cell
            } else {
                let cell: FriendVoiceCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
//                cell.backgroundColor = UIColor.white
                cell.update(viewModel: message)
                cell.setCellDelegate(delegate: self)
                return cell
            }
        default:
            NSLog("Wrong choice")
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRow(indexPath: indexPath, cellFrame: self.view.frame)
    }
    
    //MARK: Paging
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (decelerate) {return}
        configurePaginationWindow()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        configurePaginationWindow()
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        configurePaginationWindow()
    }
    
    func configurePaginationWindow() {
        if (self.tableView.frame.equalTo(CGRect.zero)) {return}
        if (self.tableView.isDragging) {return}
        if (self.tableView.isDecelerating) {return}
        let topOffset = -self.tableView.contentInset.top
        let distanceFromTop = self.tableView.contentOffset.y - topOffset
        let minimumDistanceFromTopToTriggerLoadingMore: CGFloat = 200
        let nearTop = distanceFromTop <= minimumDistanceFromTopToTriggerLoadingMore
        if (!nearTop) {return}
        
        self.viewModel.nextPage()
    }
}

extension ALConversationViewController: AudioPlayerProtocol, VoiceCellProtocol {
    
    func reloadVoiceCell() {
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else {return}
            if let message = viewModel.messageForRow(indexPath: indexPath) {
                if message.messageType == .voice && message.identifier == audioPlayer.getCurrentAudioTrack(){
                    print("voice cell reloaded with row: ", indexPath.row, indexPath.section)
                    tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .none)
                    break
                }
            }
        }
    }
    
    //MAKR: Voice and Audio Delegate
    func playAudioPress(identifier: String) {
        DispatchQueue.main.async { [weak self] in
            NSLog("play audio pressed")
            guard let weakSelf = self else { return }
            
            //if we have previously play audio, stop it first
            if !weakSelf.audioPlayer.getCurrentAudioTrack().isEmpty && weakSelf.audioPlayer.getCurrentAudioTrack() != identifier {
                //pause
                NSLog("already playing, change it to pause")
                guard var lastMessage =  weakSelf.viewModel.messageForRow(identifier: weakSelf.audioPlayer.getCurrentAudioTrack()) else {return}
                
                if Int(lastMessage.voiceCurrentDuration) > 0 {
                    lastMessage.voiceCurrentState = .pause
                    lastMessage.voiceCurrentDuration = weakSelf.audioPlayer.secLeft
                } else {
                    lastMessage.voiceCurrentDuration = lastMessage.voiceTotalDuration
                    lastMessage.voiceCurrentState = .stop
                }
                weakSelf.audioPlayer.pauseAudio()
            }
            NSLog("now it will be played")
            //now play
            guard var currentVoice =  weakSelf.viewModel.messageForRow(identifier: identifier) else {return}
            if currentVoice.voiceCurrentState == .playing {
                currentVoice.voiceCurrentState = .pause
                currentVoice.voiceCurrentDuration = weakSelf.audioPlayer.secLeft
                weakSelf.audioPlayer.pauseAudio()
                weakSelf.tableView.reloadData()
            }
            else {
                NSLog("reset time to total duration")
                //reset time to total duration
                if currentVoice.voiceCurrentState  == .stop || currentVoice.voiceCurrentDuration < 1 {
                    currentVoice.voiceCurrentDuration = currentVoice.voiceTotalDuration
                }
                
                if let data = currentVoice.voiceData {
                    let voice = data as NSData
                    //start playing
                    NSLog("Start playing")
                    weakSelf.audioPlayer.setAudioFile(data: voice, delegate: weakSelf, playFrom: currentVoice.voiceCurrentDuration,lastPlayTrack:currentVoice.identifier)
                    currentVoice.voiceCurrentState = .playing
                    weakSelf.tableView.reloadData()
                }
            }
        }
        
    }
    
    func audioPlaying(maxDuratation: CGFloat, atSec: CGFloat,lastPlayTrack:String) {
        
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            guard var currentVoice =  weakSelf.viewModel.messageForRow(identifier: lastPlayTrack) else {return}
            if currentVoice.messageType == .voice {
                
                if currentVoice.identifier == lastPlayTrack {
                    if atSec <= 0 {
                        currentVoice.voiceCurrentState = .stop
                        currentVoice.voiceCurrentDuration = 0
                    } else {
                        currentVoice.voiceCurrentState = .playing
                        currentVoice.voiceCurrentDuration = atSec
                    }
                }
                print("audio playing id: ", currentVoice.identifier)
                weakSelf.reloadVoiceCell()
            }
        }
    }
    
    func audioStop(maxDuratation: CGFloat,lastPlayTrack:String) {
        
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            
            guard var currentVoice =  weakSelf.viewModel.messageForRow(identifier: lastPlayTrack) else {return}
            if currentVoice.messageType == .voice {
                if currentVoice.identifier == lastPlayTrack {
                    currentVoice.voiceCurrentState = .stop
                    currentVoice.voiceCurrentDuration = 0.0
                }
            }
            weakSelf.reloadVoiceCell()
        }
    }
    
    func stopAudioPlayer(){
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            if var lastMessage = weakSelf.viewModel.messageForRow(identifier: weakSelf.audioPlayer.getCurrentAudioTrack()) {
                
                if lastMessage.voiceCurrentState == .playing {
                    weakSelf.audioPlayer.pauseAudio()
                    lastMessage.voiceCurrentState = .pause
                    weakSelf.reloadVoiceCell()
                }
            }
        }
    }
}
