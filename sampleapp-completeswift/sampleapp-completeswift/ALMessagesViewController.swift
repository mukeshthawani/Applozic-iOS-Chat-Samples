//
//  ALMessagesViewController.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import Applozic

class ALMessagesViewController: ALBaseViewController {
    
    var viewModel: ALMessagesViewModel!
    
    // To check if coming from push notification
    var contactId: String?
    
    fileprivate var tapToDismiss:UITapGestureRecognizer!
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchActive : Bool = false
    fileprivate var searchFilteredChat:[Any] = []
    fileprivate var alMqttConversationService: ALMQTTConversationService!
    fileprivate var conversationViewController: ALConversationViewController?
    
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
    
    override func addObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "pushNotification"), object: nil, queue: nil, using: {[weak self] notification in
            print("push notification received: ", notification.object)
            
        })
    }
    
    override func removeObserver() {
        alMqttConversationService.unsubscribeToConversation()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "pushNotification"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ALMessagesViewModel()
        setupView()
        viewModel.prepareController()
        alMqttConversationService = ALMQTTConversationService.sharedInstance()
        alMqttConversationService.mqttConversationDelegate = self
        alMqttConversationService.subscribeToConversation()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("contact id: ", contactId)
        if let contactId = contactId {
            print("contact id present")
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle(for: ALConversationViewController.self))
            let convViewModel = ALConversationViewModel(contactId: contactId)
            convViewModel.individualLaunch = true
            conversationViewController = storyBoard.instantiateViewController(withIdentifier: "ALConversationViewController") as? ALConversationViewController
            conversationViewController?.viewModel = convViewModel
            self.navigationController?.pushViewController(conversationViewController!, animated: false)
            self.contactId = nil
        }
    }
    
    private func setupView() {
        
        title = "My Chats"
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "fill_214"), style: .plain, target: self, action: #selector(compose))
        rightBarButtonItem.tintColor = .white
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        #if DEVELOPMENT
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            indicator.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            indicator.hidesWhenStopped = true
            indicator.stopAnimating()
            let indicatorButton = UIBarButtonItem(customView: indicator)
            
            navigationItem.leftBarButtonItem = indicatorButton
        #endif
        view.addViewsForAutolayout(views: [tableView])
        
//         tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        //TEMPORARY: Remove this
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        
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
    
    func compose() {
        
    }

}

extension ALMessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if searchActive {
//            return searchFilteredChat.count
//        }
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let chat = viewModel.chatForRow(indexPath: indexPath) else {
            return UITableViewCell()
        }
//
//        let identity = viewModel.identityWith(for: chat.friendIdentifier ?? "")
        let cell: ChatCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.update(viewModel: chat, identity: nil)
//        cell.setComingSoonDelegate(delegate: self.view)
////        cell.chatCellDelegate = self
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
        guard let chat = viewModel.chatForRow(indexPath: indexPath) else { return }
        let id: String = chat.contactId
        let convViewModel = ALConversationViewModel(contactId: id)
        conversationViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: ALConversationViewController.self)) as? ALConversationViewController
        
        conversationViewController?.viewModel = convViewModel
//        let vc = ALConversationViewController(viewModel: convViewModel)
        self.navigationController?.pushViewController(conversationViewController!, animated: false)
        
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

extension ALMessagesViewController: ALMQTTConversationDelegate {
    
    func mqttDidConnected() {
        print("MQTT did connected")
    }
    
    
    func syncCall(_ alMessage: ALMessage!, andMessageList messageArray: NSMutableArray!) {
        
    }
    
    func delivered(_ messageKey: String!, contactId: String!, withStatus status: Int32) {
        
    }
    
    func updateStatus(forContact contactId: String!, withStatus status: Int32) {
        
    }
    
    func updateTypingStatus(_ applicationKey: String!, userId: String!, status: Bool) {
        print("Typing status is", status)
        guard let viewController = conversationViewController, viewController.viewModel.contactId == userId else { return
        }
        print("Contact id matched")
        viewModel.updateTypingStatus(in: viewController, userId: userId, status: status)
        
    }
    
    func updateLastSeen(atStatus alUserDetail: ALUserDetail!) {
        print("Last seen updated")
    }
    
    func mqttConnectionClosed() {
        NSLog("MQTT connection closed")
    }
}

