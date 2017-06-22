//
//  ConversationListViewController.swift
//  Axiata
//
//  Created by Nitigron Ruengmontre on 12/6/2559 BE.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI
import Applozic

final class ConversationListViewController: ALBaseViewController {
    
    var viewModel: ConversationListViewModel!

    // To check if coming from push notification
    var contactId: String?
    var channelKey: NSNumber?

    fileprivate var tapToDismiss:UITapGestureRecognizer!
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchActive : Bool = false
    fileprivate var searchFilteredChat:[Any] = []
    fileprivate var alMqttConversationService: ALMQTTConversationService!
    fileprivate var conversationViewController: ConversationViewController?
    fileprivate var dbService: ALMessageDBService!

    fileprivate let tableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.estimatedRowHeight = 69
        tv.rowHeight = 69
        tv.separatorStyle = .none
        tv.backgroundColor = UIColor.white
        tv.keyboardDismissMode = .onDrag
        return tv
    }()

    fileprivate lazy var searchBar: UISearchBar = {
        var bar = UISearchBar()
        bar.autocapitalizationType = .sentences
        return bar
    }()

    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func addObserver() {

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "newMessageNotification"), object: nil, queue: nil, using: {[weak self] notification in
            guard let weakSelf = self, let viewModel = weakSelf.viewModel else { return }
            let msgArray = notification.object as? [ALMessage]
            print("new notification received: ", msgArray?.first?.message)
            guard let list = notification.object as? [Any], !list.isEmpty else { return }
            viewModel.addMessages(messages: list)

        })


        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "pushNotification"), object: nil, queue: nil, using: {[weak self] notification in
            print("push notification received: ", notification.object)
            guard let weakSelf = self, let object = notification.object as? String else { return }
            let components = object.components(separatedBy: ":")
            var groupId: NSNumber? = nil
            var contactId: String? = nil
            if components.count > 1 {
                let id = NSNumber(integerLiteral: Int(components[1])!)
                groupId = id

            } else {
                contactId = object
            }
            let message = ALMessage()
            message.contactIds = contactId
            message.groupId = groupId
            let info = notification.userInfo
            let alertValue = info?["alertValue"]
            guard let updateUI = info?["updateUI"] as? Int else { return }
            if updateUI == Int(APP_STATE_ACTIVE.rawValue), weakSelf.isViewLoaded, (weakSelf.view.window != nil) {
                guard let alert = alertValue as? String else { return }
                let alertComponents = alert.components(separatedBy: ":")
                if alertComponents.count > 1 {
                    message.message = alertComponents[1]
                } else {
                    message.message = alertComponents.first
                }
                weakSelf.viewModel.addMessages(messages: [message])
            } else if updateUI == Int(APP_STATE_BACKGROUND.rawValue) {
                // Coming from background

                guard contactId != nil || groupId != nil else { return }
               weakSelf.launchChat(contactId: contactId, groupId: groupId)
            }
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "reloadTable"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("Reloadtable notification received")

            guard let weakSelf = self, let list = notification.object as? [Any] else { return }
            weakSelf.viewModel.updateMessageList(messages: list)
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "USER_DETAILS_UPDATE_CALL"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("update user detail notification received")

            guard let weakSelf = self, let userId = notification.object as? String else { return }
            print("update user detail")
            ALUserService.updateUserDetail(userId, withCompletion: {
                userDetail in
                guard let detail = userDetail else { return }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USER_DETAIL_OTHER_VC"), object: detail)
                weakSelf.tableView.reloadData()
            })
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UPDATE_CHANNEL_NAME"), object: nil, queue: nil, using: {[weak self] notification in
            NSLog("update group name notification received")
            guard let weakSelf = self, (weakSelf.view.window != nil) else { return }
            print("update group detail")
            weakSelf.tableView.reloadData()
        })

    }

    override func removeObserver() {
        if let alMqtt = alMqttConversationService {
            alMqttConversationService.unsubscribeToConversation()
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "pushNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMessageNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "USER_DETAILS_UPDATE_CALL"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UPDATE_CHANNEL_NAME"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dbService = ALMessageDBService()
        dbService.delegate = self
        viewModel = ConversationListViewModel()
        viewModel.delegate = self
        viewModel.prepareController(dbService: dbService)
        self.edgesForExtendedLayout = []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        searchBar.delegate = self
        alMqttConversationService = ALMQTTConversationService.sharedInstance()
        alMqttConversationService.mqttConversationDelegate = self
        alMqttConversationService.subscribeToConversation()
        conversationViewController = ConversationViewController()
        conversationViewController?.viewModel = ConversationViewModel(contactId: nil, channelKey: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        print("contact id: ", contactId)
        if contactId != nil || channelKey != nil {
            print("contact id present")
            launchChat(contactId: contactId, groupId: channelKey)
            self.contactId = nil
            self.channelKey = nil
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let text = searchBar.text, !text.isEmpty {
            searchBar.text = ""
        }
        searchBar.endEditing(true)
        searchActive = false
        tableView.reloadData()
    }

    private func setupView() {

        title = "My Chats"

        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "fill_214"), style: .plain, target: self, action: #selector(compose))
        rightBarButtonItem.tintColor = .white
        navigationItem.rightBarButtonItem = rightBarButtonItem

        let leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(customBackAction))
        leftBarButtonItem.tintColor = .white
        navigationItem.leftBarButtonItem = leftBarButtonItem

        #if DEVELOPMENT
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            indicator.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            indicator.hidesWhenStopped = true
            indicator.stopAnimating()
            let indicatorButton = UIBarButtonItem(customView: indicator)

            navigationItem.leftBarButtonItem = indicatorButton
        #endif
        view.addViewsForAutolayout(views: [tableView])

        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.register(ChatCell.self)

        let nib = UINib(nibName: "EmptyChatCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "EmptyChatCell")

    }

    func launchChat(contactId: String?, groupId: NSNumber?) {
        let alChannelService = ALChannelService()
        let alContactDbService = ALContactDBService()
        var title = ""
        if let key = groupId, let alChannel = alChannelService.getChannelByKey(key), let name = alChannel.name {
            title = name
        }
        else if let key = contactId,let alContact = alContactDbService.loadContact(byKey: "userId", value: key), let name = alContact.displayName {
            title = name
        }
        title = title.isEmpty ? "No name":title
        let convViewModel = ConversationViewModel(contactId: contactId, channelKey: channelKey)
        conversationViewController = ConversationViewController()
        conversationViewController?.title = title
        conversationViewController?.viewModel = convViewModel
        self.navigationController?.pushViewController(conversationViewController!, animated: false)
    }

    func compose() {
        let newChatVC = NewChatViewController(viewModel: NewChatViewModel())
        navigationController?.pushViewController(newChatVC, animated: true)
    }

    func sync(message: ALMessage) {
        if let viewController = conversationViewController, viewController.viewModel.contactId == message.contactId,viewController.viewModel.channelKey == message.groupId {
            print("Contact id matched1")
            viewController.viewModel.addMessagesToList([message])
        }
        if let dbService = dbService {
            viewModel.prepareController(dbService: dbService)
        }
    }

    //MARK: - Handle keyboard
    override func hideKeyboard()
    {
        tapToDismiss = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tapToDismiss)
    }

    override func dismissKeyboard()
    {
        searchBar.endEditing(true)
        view.endEditing(true)
    }

    func customBackAction() {
        guard let nav = self.navigationController else { return }
        let dd = nav.popViewController(animated: true)
        if dd == nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return searchFilteredChat.count
        }
        return viewModel.numberOfRowsInSection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        guard let chat = (searchActive ? searchFilteredChat[indexPath.row] as? ALMessage : viewModel.chatForRow(indexPath: indexPath)) else {
            return UITableViewCell()
        }
        let cell: ChatCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.update(viewModel: chat, identity: nil)
//        cell.setComingSoonDelegate(delegate: self.view)
        cell.chatCellDelegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //        Logger.verbose(message: "Start to selected chatroom in My Chats.", tag: .tapChatRoomUntilFetchMessage)

        //        if let chatViewModel = self.viewModel.chatForRow(indexPath: indexPath), let conversation = self.viewModel.conversation(for: chatViewModel.identifier){
        //
        //            tableView.isUserInteractionEnabled = false
        //
        //            let cache = RowHeighCache(identity: conversation.identifier.absoluteString)
        //            let viewModel = ConversationViewModel(conversation: conversation, cache: cache)
        //
        //            viewModel.fetch(complete: { [weak self] (_) in
        //
        //                guard let strongSelf = self else {return}
        //
        //                let conversationVC = ConversationViewController(viewModel: viewModel)
        //                conversationVC.title = viewModel.title()
        //
        //                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
        //                strongSelf.navigationController?.pushViewController(conversationVC, animated: true)
        //                strongSelf.tableView.isUserInteractionEnabled = true
        //            })
        //        } else {
        //            tableView.deselectRow(at: indexPath, animated: true)
        //        }
        if searchActive {
            guard let chat = searchFilteredChat[indexPath.row] as? ALMessage else {return}
            let convViewModel = ConversationViewModel(contactId: chat.contactId, channelKey: chat.channelKey)
            conversationViewController = ConversationViewController()
            conversationViewController?.title = chat.isGroupChat ? chat.groupName:chat.name
            conversationViewController?.viewModel = convViewModel
            guard let vc = conversationViewController else {
                NSLog("view controller is empty")
                return
            }
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            guard let chat = viewModel.chatForRow(indexPath: indexPath) else { return }
            let convViewModel = ConversationViewModel(contactId: chat.contactId, channelKey: chat.channelKey)
            conversationViewController = ConversationViewController()
            conversationViewController?.title = chat.isGroupChat ? chat.groupName:chat.name
            conversationViewController?.viewModel = convViewModel
            guard let vc = conversationViewController else {
                NSLog("view controller is empty")
                return
            }
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let view = tableView.dequeueReusableCell(withIdentifier: "EmptyChatCell")?.contentView

        if let tap = view?.gestureRecognizers?.first {
            view?.removeGestureRecognizer(tap)
        }

        let tap = UITapGestureRecognizer.init(target: self, action: #selector(compose))
        tap.numberOfTapsRequired = 1

        view?.addGestureRecognizer(tap)

        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.numberOfRowsInSection(section: 0) == 0 ? 325 : 0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension ConversationListViewController: ALMessagesDelegate {
    func getMessagesArray(_ messagesArray: NSMutableArray!) {
        print("message array: ", messagesArray.map { ($0 as! ALMessage).message})
        print("message read: ", messagesArray.map { ($0 as! ALMessage).totalNumberOfUnreadMessages})
        guard let messages = messagesArray as? [Any] else {
            return
        }
        viewModel.updateMessageList(messages: messages)
    }

    func updateMessageList(_ messagesArray: NSMutableArray!) {
        print("updated message array: ", messagesArray)
    }
}

extension ConversationListViewController: ConversationListViewModelDelegate {
    func listUpdated() {
        tableView.reloadData()
    }
}

extension ConversationListViewController: ALMQTTConversationDelegate {

    func mqttDidConnected() {
        print("MQTT did connected")
    }

    func updateUserDetail(_ userId: String!) {
        guard let userId = userId else { return }
        print("update user detail")

        ALUserService.updateUserDetail(userId, withCompletion: {
            userDetail in
            guard let detail = userDetail else { return }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "USER_DETAIL_OTHER_VC"), object: detail)
            self.tableView.reloadData()
        })
    }


    func syncCall(_ alMessage: ALMessage!, andMessageList messageArray: NSMutableArray!) {
        print("sync call: ", alMessage.message)
//        sync(message: alMessage)
        }

    func delivered(_ messageKey: String!, contactId: String!, withStatus status: Int32) {
        viewModel.updateDeliveryReport(convVC: conversationViewController, messageKey: messageKey, contactId: contactId, status: status)
    }

    func updateStatus(forContact contactId: String!, withStatus status: Int32) {
        viewModel.updateStatusReport(convVC: conversationViewController, forContact: contactId, status: status)
    }

    func updateTypingStatus(_ applicationKey: String!, userId: String!, status: Bool) {
        print("Typing status is", status)
        guard let viewController = conversationViewController,let vm = viewController.viewModel, let id = vm.contactId, id == userId else { return
        }
        print("Contact id matched")
        viewModel.updateTypingStatus(in: viewController, userId: userId, status: status)

    }

    func reloadData(forUserBlockNotification userId: String!, andBlockFlag flag: Bool) {
        print("reload data")
    }

    func updateLastSeen(atStatus alUserDetail: ALUserDetail!) {
        print("Last seen updated")
    }
    
    func mqttConnectionClosed() {
        NSLog("MQTT connection closed")
    }
}

extension ConversationListViewController: UISearchResultsUpdating,UISearchBarDelegate {

    func filterContentForSearchText(searchText: String, scope: String = "All") {
        searchFilteredChat = viewModel.getChatList().filter { (chatViewModel) -> Bool in
            guard let conversation = chatViewModel as? ALMessage else {
                return false
            }
            if conversation.isGroupChat {
                return conversation.groupName.lowercased().isCompose(of: searchText.lowercased())
            } else {
                return conversation.name.lowercased().isCompose(of: searchText.lowercased())
            }
        }
        self.tableView.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        searchFilteredChat = viewModel.getChatList().filter { (chatViewModel) -> Bool in
            guard let conversation = chatViewModel as? ALMessage else {
                return false
            }
            if conversation.isGroupChat {
                return conversation.groupName.lowercased().isCompose(of: searchText.lowercased())
            } else {
                return conversation.name.lowercased().isCompose(of: searchText.lowercased())
            }
        }
        searchActive = !searchText.isEmpty
        self.tableView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        hideKeyboard()

        if(searchBar.text?.isEmpty)! {
            self.tableView.reloadData()
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

        view.removeGestureRecognizer(tapToDismiss)

        guard let text = searchBar.text else { return }

        if text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            if searchActive {
                searchActive = false
            }
            tableView.reloadData()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
    }

}

extension ConversationListViewController: ChatCellDelegate {

    func chatCell(cell: ChatCell, action: ChatCellAction, viewModel: ChatViewModelProtocol) {

        switch action {

        case .delete:

            guard let indexPath = self.tableView.indexPath(for: cell) else {return}
//            guard let account = ChatManager.shared.currentUser else {return}

            //TODO: Add activity indicator

            if searchActive {
                guard let conversation = searchFilteredChat[indexPath.row] as? ALMessage else {return}

                let prefixText = conversation.isGroupChat ? SystemMessage.Warning.DeleteGroupConversation : SystemMessage.Warning.DeleteSingleConversation
                let name = conversation.isGroupChat ? conversation.groupName : conversation.name
                let text = "\(prefixText) \(name)?"
                let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
                let cancelBotton = UIAlertAction(title: SystemMessage.ButtonName.Cancel, style: .cancel, handler: nil)
                let deleteBotton = UIAlertAction(title: SystemMessage.ButtonName.Remove, style: .destructive, handler: { [weak self] (alert) in
                    guard let weakSelf = self, ALDataNetworkConnection.checkDataNetworkAvailable() else { return }

                    if conversation.isGroupChat {
                        let channelService = ALChannelService()
                        if  channelService.isChannelLeft(conversation.groupId) {
                            weakSelf.dbService.deleteAllMessages(byContact: nil, orChannelKey: conversation.groupId)
                            ALChannelService.setUnreadCountZeroForGroupID(conversation.groupId)
                            weakSelf.searchFilteredChat.remove(at: indexPath.row)
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        } else if ALChannelService.isChannelDeleted(conversation.groupId) {
                            let channelDbService = ALChannelDBService()
                            channelDbService.deleteChannel(conversation.groupId)
                            weakSelf.searchFilteredChat.remove(at: indexPath.row)
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        } else {
                            channelService.leaveChannel(conversation.groupId, andUserId: ALUserDefaultsHandler.getUserId(), orClientChannelKey: nil, withCompletion: {
                                error in
                                ALMessageService.deleteMessageThread(nil, orChannelKey: conversation.groupId, withCompletion: {
                                    _,error in
                                    guard error == nil else { return }
                                    weakSelf.searchFilteredChat.remove(at: indexPath.row)
                                    weakSelf.viewModel.remove(message: conversation)
                                    weakSelf.tableView.reloadData()
                                    return
                                })
                            })
                        }
                    } else {
                        ALMessageService.deleteMessageThread(conversation.contactIds, orChannelKey: nil, withCompletion: {
                            _,error in
                            guard error == nil else { return }
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        })
                    }
                })
                alert.addAction(cancelBotton)
                alert.addAction(deleteBotton)
                present(alert, animated: true, completion: nil)
            }
            else if let chatViewModel = self.viewModel.chatForRow(indexPath: indexPath), let conversation = self.viewModel.getChatList()[indexPath.row] as? ALMessage {

                let prefixText = conversation.isGroupChat ? SystemMessage.Warning.DeleteGroupConversation : SystemMessage.Warning.DeleteSingleConversation
                let name = conversation.isGroupChat ? conversation.groupName : conversation.name
                let text = "\(prefixText) \(name)?"
                let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
                let cancelBotton = UIAlertAction(title: SystemMessage.ButtonName.Cancel, style: .cancel, handler: nil)
                let deleteBotton = UIAlertAction(title: SystemMessage.ButtonName.Remove, style: .destructive, handler: { [weak self] (alert) in
                    guard let weakSelf = self else { return }
                    if conversation.isGroupChat {
                        let channelService = ALChannelService()
                        if  channelService.isChannelLeft(conversation.groupId) {
                            weakSelf.dbService.deleteAllMessages(byContact: nil, orChannelKey: conversation.groupId)
                            ALChannelService.setUnreadCountZeroForGroupID(conversation.groupId)
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        } else if ALChannelService.isChannelDeleted(conversation.groupId) {
                            let channelDbService = ALChannelDBService()
                            channelDbService.deleteChannel(conversation.groupId)
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        } else {
                            channelService.leaveChannel(conversation.groupId, andUserId: ALUserDefaultsHandler.getUserId(), orClientChannelKey: nil, withCompletion: {
                                error in
                                ALMessageService.deleteMessageThread(nil, orChannelKey: conversation.groupId, withCompletion: {
                                    _,error in
                                    guard error == nil else { return }
                                    weakSelf.viewModel.remove(message: conversation)
                                    weakSelf.tableView.reloadData()
                                    return
                                })
                            })
                        }
                    } else {
                        ALMessageService.deleteMessageThread(conversation.contactIds, orChannelKey: nil, withCompletion: {
                            _,error in
                            guard error == nil else { return }
                            weakSelf.viewModel.remove(message: conversation)
                            weakSelf.tableView.reloadData()
                        })
                    }
                })
                alert.addAction(cancelBotton)
                alert.addAction(deleteBotton)
                present(alert, animated: true, completion: nil)

            }
            break

        case .favorite:
//            self.view.makeToast(SystemMessage.ComingSoon.Favorite, duration: 1.0, position: .center)
            break
        case .mute:
//            self.view.makeToast(SystemMessage.ComingSoon.Mute, duration: 1.0, position: .center)
            break
        case .store:
//            self.view.makeToast(SystemMessage.ComingSoon.Store, duration: 1.0, position: .center)
            break
        default:
            print("not present")
        }
    }
}

