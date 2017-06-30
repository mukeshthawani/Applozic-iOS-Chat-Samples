//
//  ConversationViewController.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import MBProgressHUD
import Applozic

final class ConversationViewController: ALBaseViewController {

    var viewModel: ConversationViewModel!
    private var isFirstTime = true
    private var bottomConstraint: NSLayoutConstraint?
    private var leftMoreBarConstraint: NSLayoutConstraint?
    private var typingNoticeViewHeighConstaint: NSLayoutConstraint?
    private var isJustSent: Bool = false
    let audioPlayer = AudioPlayer()

    fileprivate let moreBar: MoreBar = MoreBar(frame: .zero)
    fileprivate let typingNoticeView = TypingNotice()
    fileprivate var alMqttConversationService: ALMQTTConversationService!

    fileprivate var keyboardSize: CGRect?

    let tableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.separatorStyle   = .none
        tv.allowsSelection  = false
        tv.backgroundColor  = UIColor.white
        tv.clipsToBounds    = true
        return tv
    }()

    fileprivate let titleButton : UIButton = {
        let titleButton = UIButton()
        titleButton.titleLabel?.textColor   = .white
        titleButton.titleLabel?.font        = UIFont.boldSystemFont(ofSize: 17.0)
        return titleButton
    }()

    let chatBar: ChatBar = ChatBar(frame: .zero)

    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func addObserver() {

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil, using: { [weak self]
            notification in
            print("keyboard will show")
            guard let weakSelf = self else {return}

            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

                weakSelf.keyboardSize = keyboardSize

                let tableView = weakSelf.tableView
                let isAtBotom = tableView.isAtBottom
                let isJustSent = weakSelf.isJustSent

                let view = weakSelf.view
                let navigationController = weakSelf.navigationController


                var h = CGFloat(0)
                h = keyboardSize.height-h

                let newH = -1*h
                if weakSelf.bottomConstraint?.constant == newH {return}

                weakSelf.bottomConstraint?.constant = newH

                let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.05

                UIView.animate(withDuration: duration, animations: {
                    view?.layoutIfNeeded()
                }, completion: { (_) in
                    print("animated ")
                    if isAtBotom == true && isJustSent == false {
                        tableView.scrollToBottomByOfset(animated: false)
                    }
                })
            }
        })


        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil, using: {[weak self]
            (notification) in

            guard let weakSelf = self else {return}
            let view = weakSelf.view

            weakSelf.bottomConstraint?.constant = 0

            let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.05

            UIView.animate(withDuration: duration, animations: {
                view?.layoutIfNeeded()
            }, completion: { (_) in
                guard let vm = weakSelf.viewModel else { return }
                vm.sendKeyboardDoneTyping()
            })

        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "newMessageNotification"), object: nil, queue: nil, using: { [weak self]
            notification in
            guard let weakSelf = self else { return }
            let msgArray = notification.object as? [ALMessage]
            print("new notification received: ", msgArray?.first?.message, msgArray?.count)
            guard let list = notification.object as? [Any], !list.isEmpty, weakSelf.isViewLoaded, weakSelf.viewModel != nil else { return }
            weakSelf.viewModel.addMessagesToList(list)
//            weakSelf.handlePushNotification = false
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "notificationIndividualChat"), object: nil, queue: nil, using: {[weak self]
            notification in
            print("notification individual chat received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "report_DELIVERED"), object: nil, queue: nil, using: {[weak self]
            notification in
            guard let weakSelf = self, let key = notification.object as? String else { return }
            weakSelf.viewModel.updateDeliveryReport(messageKey: key, status: Int32(DELIVERED.rawValue))
            print("report delievered notification received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "report_DELIVERED_READ"), object: nil, queue: nil, using: {[weak self]
            notification in
            guard let weakSelf = self, let key = notification.object as? String else { return }
            weakSelf.viewModel.updateDeliveryReport(messageKey: key, status: Int32(DELIVERED_AND_READ.rawValue))
            print("report delievered and read notification received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "report_CONVERSATION_DELIVERED_READ"), object: nil, queue: nil, using: {[weak self]
            notification in
            guard let weakSelf = self, let key = notification.object as? String else { return }
            weakSelf.viewModel.updateStatusReportForConversation(contactId: key, status: Int32(DELIVERED_AND_READ.rawValue))
            print("report conversation delievered and read notification received")
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UPDATE_MESSAGE_SEND_STATUS"), object: nil, queue: nil, using: {[weak self]
            notification in
            print("Message sent notification received")
            guard let weakSelf = self, let message = notification.object as? ALMessage else { return }
            weakSelf.viewModel.updateSendStatus(message: message)
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "USER_DETAILS_UPDATE_CALL"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("update user detail notification received")
            guard let weakSelf = self, let userId = notification.object as? String else { return }
            print("update user detail")
            ALUserService.updateUserDetail(userId, withCompletion: {
                userDetail in
                guard let detail = userDetail else { return }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USER_DETAIL_OTHER_VC"), object: detail)
                guard !weakSelf.viewModel.isGroup && userId == weakSelf.viewModel.contactId else { return }
                weakSelf.titleButton.setTitle(detail.getDisplayName(), for: .normal)
            })
        })
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UPDATE_CHANNEL_NAME"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("update group name notification received")
            guard let weakSelf = self else { return }
            print("update group detail")
            guard weakSelf.viewModel.isGroup else { return }
            let alChannelService = ALChannelService()
            guard let key = weakSelf.viewModel.channelKey, let channel = alChannelService.getChannelByKey(key), let name = channel.name else { return }
            weakSelf.titleButton.setTitle(name, for: .normal)
            })
    }

    override func removeObserver() {

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notificationIndividualChat"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "report_DELIVERED"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "report_DELIVERED_READ"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "report_CONVERSATION_DELIVERED_READ"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UPDATE_MESSAGE_SEND_STATUS"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "USER_DETAILS_UPDATE_CALL"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UPDATE_CHANNEL_NAME"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.white
        self.edgesForExtendedLayout = []
        if let listVC = self.navigationController?.viewControllers.first as? ConversationListViewController, !listVC.isViewLoaded {
            viewModel.individualLaunch = true
        } else {
            viewModel.individualLaunch = false
        }
        alMqttConversationService = ALMQTTConversationService.sharedInstance()
        if viewModel.individualLaunch {
            alMqttConversationService.mqttConversationDelegate = self
            alMqttConversationService.subscribeToConversation()
        }

        if self.viewModel.isGroupConversation() == true {
            self.setTypingNotiDisplayName(displayName: "Somebody")
        } else {
            self.setTypingNotiDisplayName(displayName: self.title ?? "")
        }

        viewModel.delegate = self
        viewModel.prepareController()
        if self.isFirstTime {
            self.setupNavigation()
        } else {
            tableView.reloadData()
        }
        subscribingChannel()
        print("id: ", viewModel.messageModels.first?.contactId)
    }

    override func viewDidAppear(_ animated: Bool) {
        NSLog("view loaded first time \(isFirstTime)")
        setupView()
        viewModel.markConversationRead()
//        isFirstTime = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ALUserDefaultsHandler.setDebugLogsRequire(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.isFirstTime && tableView.isCellVisible(section: 0, row: 0) {
            self.tableView.scrollToBottomByOfset(animated: false)
            isFirstTime = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAudioPlayer()
        chatBar.stopRecording()
        if viewModel.individualLaunch {
            if let _ = alMqttConversationService {
                alMqttConversationService.unsubscribeToConversation()
            }
        }
        unsubscribingChannel()
    }

    override func backTapped() {
        print("back tapped")
        self.viewModel.sendKeyboardDoneTyping()
        _ = navigationController?.popToRootViewController(animated: true)

//        navigationController?.popViewController(animated: true)
    }

    func setupView() {
        view.addViewsForAutolayout(views: [tableView,moreBar,chatBar,typingNoticeView])

        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: typingNoticeView.topAnchor).isActive = true

        typingNoticeViewHeighConstaint = typingNoticeView.heightAnchor.constraint(equalToConstant: 0)
        typingNoticeViewHeighConstaint?.isActive = true

        typingNoticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        typingNoticeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).isActive = true
        typingNoticeView.bottomAnchor.constraint(equalTo: chatBar.topAnchor).isActive = true

        chatBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chatBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = chatBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint?.isActive = true

        leftMoreBarConstraint = moreBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 56)
        leftMoreBarConstraint?.isActive = true
        prepareTable()
        prepareMoreBar()
        prepareChatBar()

    }

    private func setupNavigation() {

        titleButton.setTitle(self.title, for: .normal)
        titleButton.addTarget(self, action: #selector(showParticipantListChat), for: .touchUpInside)
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
        tableView.register(InformationCell.self)
        tableView.register(MyLocationCell.self)
        tableView.register(FriendLocationCell.self)
    }


    private func prepareMoreBar() {

        moreBar.bottomAnchor.constraint(equalTo: chatBar.topAnchor).isActive = true
        moreBar.isHidden = true
        moreBar.setHandleAction { [weak self] (actionType) in
//            self?.view.makeToast(SystemMessage.ComingSoon.ExtraMenu, duration: 1.0, position: .center)
            self?.hideMoreBar()
        }

        moreBar.setPresenterVC(delegate: self)
    }


    private func prepareChatBar() {
        chatBar.accessibilityIdentifier = "chatBar"
        chatBar.setComingSoonDelegate(delegate: self.view)
        chatBar.action = { [weak self] (action) in

            guard let weakSelf = self else {
                return
            }

            if case .more(_) = action {

                if weakSelf.moreBar.isHidden == true {
                    weakSelf.showMoreBar()
                } else {
                    weakSelf.hideMoreBar()
                }

                return
            }

            weakSelf.hideMoreBar()

            switch action {

            case .sendText(let button, let message):

                if message.characters.count < 1 {
                    return
                }

                button.isUserInteractionEnabled = false
                weakSelf.viewModel.sendKeyboardDoneTyping()

                weakSelf.isJustSent = true

                weakSelf.chatBar.clear()

                NSLog("Sent: ", message)

                weakSelf.viewModel.send(message: message)
                button.isUserInteractionEnabled = true
            case .chatBarTextChange(_):

                weakSelf.viewModel.sendKeyboardBeginTyping()

                UIView.animate(withDuration: 0.05, animations: { () in
                    weakSelf.view.layoutIfNeeded()
                }, completion: { [weak self] (_) in

                    guard let weakSelf = self else {
                        return
                    }

                    if weakSelf.tableView.isAtBottom == true && weakSelf.isJustSent == false {
                        weakSelf.tableView.scrollToBottomByOfset(animated: false)
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
//                    weakSelf.view.makeToast(SystemMessage.Warning.PleaseTryAgain, duration: 1.0, position: .center)
                }
                break;
            default:
                print("Not available")
            }
        }
    }

    //MARK: public Control Typing notification
    func setTypingNotiDisplayName(displayName:String)
    {
        typingNoticeView.setDisplayName(displayName: displayName)
    }

    func tableTapped(gesture: UITapGestureRecognizer) {
        hideMoreBar()
        view.endEditing(true)
    }

    private func showMoreBar() {

        self.moreBar.isHidden = false
        self.leftMoreBarConstraint?.constant = 0

        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] () in
            self?.view.layoutIfNeeded()
            }, completion: { [weak self] (finished) in

                guard let strongSelf = self else {return}

                strongSelf.view.bringSubview(toFront: strongSelf.moreBar)
                strongSelf.view.sendSubview(toBack: strongSelf.tableView)
        })

    }

    private func hideMoreBar() {

        if self.leftMoreBarConstraint?.constant == 0 {

            self.leftMoreBarConstraint?.constant = 56

            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] () in
                self?.view.layoutIfNeeded()
                }, completion: { [weak self] (finished) in
                    self?.moreBar.isHidden = true
            })

        }

    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        UIMenuController.shared.setMenuVisible(false, animated: true)
        hideMoreBar()
    }

    // Called from the parent VC
    func showTypingLabel(status: Bool, userId: String) {
        typingNoticeViewHeighConstaint?.constant = status ? 30:0
        view.layoutIfNeeded()
        if tableView.isAtBottom {
            tableView.scrollToBottomByOfset(animated: false)
        }
    }

    @objc private func showParticipantListChat() {
//        if viewModel.isGroupConversation() {
//            let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.createGroupChat)
//            if let vc = storyboard.instantiateViewController(withIdentifier: "CreateGroupViewController") as? CreateGroupViewController {
//
//                if viewModel.groupProfileImgUrl().isEmpty {
//                    vc.setCurrentGroupSelected(groupName: viewModel.groupName(),groupProfileImg:nil, groupSelected: viewModel.friends(), delegate: self)
//                } else {
//                    vc.setCurrentGroupSelected(groupName: viewModel.groupName(),groupProfileImg:viewModel.groupProfileImgUrl(), groupSelected: viewModel.friends(), delegate: self)
//                }
//                vc.addContactMode = .existingChat
//                navigationController?.pushViewController(vc, animated: true)
//            }
//        }
    }

    func updateDeliveryReport(messageKey: String?, contactId: String?, status: Int32?) {
        guard let key = messageKey, let status = status else {
            return
        }
        viewModel.updateDeliveryReport(messageKey: key, status: status)
    }

    func updateStatusReport(contactId: String?, status: Int32?) {
        guard let id = contactId, let status = status else {
            return
        }
        viewModel.updateStatusReportForConversation(contactId: id, status: status)
    }

    private func subscribingChannel() {
        let channelService = ALChannelService()
        if viewModel.isGroup, let groupId = viewModel.channelKey, !channelService.isChannelLeft(groupId) && !ALChannelService.isChannelDeleted(groupId) {
            self.alMqttConversationService.subscribe(toChannelConversation: groupId)
        } else if !viewModel.isGroup {
            self.alMqttConversationService.subscribe(toChannelConversation: nil)
        }
        if viewModel.isGroup, ALUserDefaultsHandler.isUserLoggedInUserSubscribedMQTT(){
            self.alMqttConversationService.unSubscribe(toChannelConversation: nil)
        }

    }

    private func unsubscribingChannel() {

        self.alMqttConversationService.sendTypingStatus(ALUserDefaultsHandler.getApplicationKey(), userID: viewModel.contactId, andChannelKey: viewModel.channelKey, typing: false)
        self.alMqttConversationService.unSubscribe(toChannelConversation: viewModel.channelKey)
    }
}

extension ConversationViewController: ConversationViewModelDelegate {
    func loadingFinished(error: Error?) {
        tableView.reloadData()
        print("loading finished")
        DispatchQueue.main.async {
            if self.viewModel.isFirstTime {
                self.tableView.scrollToBottom(animated: false)
                self.viewModel.isFirstTime = false
            }
        }
    }

    func messageUpdated() {
        tableView.reloadData()
    }

    func updateMessageAt(indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            self.tableView.endUpdates()
        }
    }

    func newMessagesAdded() {
        tableView.reloadData()
        if tableView.isCellVisible(section: viewModel.messageModels.count-2, row: 0) {
            tableView.scrollToBottom()
        }
        guard self.isViewLoaded && self.view.window != nil else {
            return
        }
        viewModel.markConversationRead()
    }

    func messageSent() {
        tableView.reloadData()
        DispatchQueue.main.async {
            self.tableView.scrollToBottom(animated: false)
        }
    }
}

//extension ConversationViewController: CreateGroupChatAddFriendProtocol {
//
//    func createGroupGetFriendInGroupList(friendsSelected: [FriendViewModel], groupName: String, groupImgUrl: String, friendsAdded: [FriendViewModel]) {
//        if viewModel.isGroupConversation() {
//            self.title = groupName
//            titleButton.setTitle(self.title, for: .normal)
//            
//            viewModel.updateGroup(groupName: groupName, groupImage: groupImgUrl, friendsAdded: friendsAdded)
//
//            if let titleButton = navigationItem.titleView as? UIButton {
//                titleButton.setTitle(title, for: .normal)
//            }
//
//            let _ = navigationController?.popToViewController(self, animated: true)
//        }
//    }
//}

extension ConversationViewController: ShareLocationViewControllerDelegate {
    func locationDidSelected(geocode: Geocode, image: UIImage) {
        viewModel.send(geocode: geocode)
    }
}


extension ConversationViewController: LocationCellDelegate {
    func displayLocation(location: LocationPreviewViewModel) {
        let storyboard = UIStoryboard.name(storyboard: .previewLocation)

        guard let navigation = storyboard.instantiateInitialViewController() as? UINavigationController,let previewLocationVC = navigation.visibleViewController as? PreviewLocationViewController else {return}
        previewLocationVC.setLocationViewModel(location: location)

        if let _ = self.presentedViewController {
            return
        }else{
            self.present(navigation, animated: true, completion:nil)
        }

    }
}

extension ConversationViewController: AudioPlayerProtocol, VoiceCellProtocol {

    func reloadVoiceCell() {
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else {return}
            if let message = viewModel.messageForRow(indexPath: indexPath) {
                if message.messageType == .voice && message.identifier == audioPlayer.getCurrentAudioTrack(){
                    print("voice cell reloaded with row: ", indexPath.row, indexPath.section)
                    tableView.reloadSections([indexPath.section], with: .none)
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

extension ConversationViewController: ALMQTTConversationDelegate {

    func mqttDidConnected() {
        print("MQTT did connected")
    }


    func syncCall(_ alMessage: ALMessage!, andMessageList messageArray: NSMutableArray!) {
        print("sync call1 ", messageArray)
//        guard viewModel.contactId == alMessage.contactId, viewModel.channelKey == alMessage.channelKey, let message = alMessage else {
//            return
//        }
//        viewModel.addMessagesToList([message])
    }

    func delivered(_ messageKey: String!, contactId: String!, withStatus status: Int32) {
        updateDeliveryReport(messageKey: messageKey, contactId: contactId, status: status)
    }

    func updateStatus(forContact contactId: String!, withStatus status: Int32) {
        updateStatusReport(contactId: contactId, status: status)
    }

    func updateTypingStatus(_ applicationKey: String!, userId: String!, status: Bool) {
        print("Typing status is", status)
        guard viewModel.contactId == userId || viewModel.channelKey != nil else {
            return
        }
        print("Contact id matched")
        showTypingLabel(status: status, userId: userId)

    }

    func updateLastSeen(atStatus alUserDetail: ALUserDetail!) {
        print("Last seen updated")
    }

    func mqttConnectionClosed() {
        NSLog("MQTT connection closed")
    }

    func reloadData(forUserBlockNotification userId: String!, andBlockFlag flag: Bool) {
        print("reload data")
    }

    func updateUserDetail(_ userId: String!) {
        guard let userId = userId else { return }
        print("update user detail")

        ALUserService.updateUserDetail(userId, withCompletion: {
            userDetail in
            guard let detail = userDetail else { return }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USER_DETAIL_OTHER_VC"), object: detail)
            guard !self.viewModel.isGroup && userId == self.viewModel.contactId else { return }
            self.titleButton.setTitle(detail.getDisplayName(), for: .normal)
        })
    }
}
