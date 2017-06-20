////
////  NewChatViewController.swift
////  Axiata
////
////  Created by appsynth on 2/1/17.
////  Copyright © 2017 Appsynth. All rights reserved.
////
//
//import UIKit
//import MBProgressHUD
//import Applozic
//
//final class NewChatViewController: ALBaseViewController {
//
//    fileprivate var viewModel: NewChatViewModel
//    
//    fileprivate let tableView : UITableView = {
//        let tv = UITableView(frame: .zero, style: .plain)
//        tv.estimatedRowHeight   = 53
//        tv.rowHeight            = 53
//        tv.separatorStyle       = .none
//        tv.backgroundColor      = UIColor.white
//        tv.keyboardDismissMode  = .onDrag
//        return tv
//    }()
//    
//    fileprivate lazy var searchBar: UISearchBar = {
//        return UISearchBar.createAXSearchBar(placeholder: "Search")
//    }()
//    
//    //MARK: - Life cycle
//    
//    required init(viewModel: NewChatViewModel) {
//        self.viewModel = viewModel
//        
//        super.init(nibName: nil, bundle: nil)
//        setupView()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        searchBar.delegate = self
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        viewModel.getAllFriends {
//            self.tableView.reloadData()
//        }
//    }
//    
//    //MARK: -
//    
//    private func setupView() {
//        
//        title = "New Chat"
//        
//        view.addViewsForAutolaout(views: [tableView])
//        
//        setupTableViewConstraint()
//        
//        // Setup table view datasource/delegate
//        tableView.delegate              = self
//        tableView.dataSource            = self
//        tableView.contentInset          = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        
//        self.automaticallyAdjustsScrollViewInsets = false
//        
//        registerCell()
//    }
//    
//    private func setupTableViewConstraint() {
//        // Setup table view constraint
//        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//    }
//    
//    private func registerCell() {
//        tableView.register(FriendNewChatCell.self)
//    }
//}
//
//
////MARK: -  UITableViewDelegate, UITableViewDataSource
//extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return viewModel.numberOfSection()
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return (section == 0) ? 1 : viewModel.numberOfRowsInSection(section: section)
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let friendViewModel = (indexPath.section == 0) ? viewModel.createGroupCell() : viewModel.friendForRow(indexPath: indexPath)
//        let cell: FriendNewChatCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
//        cell.update(friend: friendViewModel)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        if indexPath.section == 0 {
//            
//            tableView.deselectRow(at: indexPath, animated: true)
//            
//            let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.createGroupChat)
//            if let vc = storyboard.instantiateViewController(withIdentifier: "CreateGroupViewController") as? CreateGroupViewController {
//                vc.setCurrentGroupSelected(groupName: "", groupProfileImg: nil, groupSelected: [FriendViewModel](), delegate: self)
//                vc.addContactMode = .newChat
//                navigationController?.pushViewController(vc, animated: true)
//            }
//
//            return
//        }
//
//
//        let friendViewModel = self.viewModel.friendForRow(indexPath: indexPath)
//
//
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        tableView.isUserInteractionEnabled = false
//
//        let viewModel = ConversationViewModel(contactId: friendViewModel.userID, channelKey: nil)
//
//        let conversationVC = ConversationViewController()
//        conversationVC.viewModel = viewModel
//        conversationVC.title = friendViewModel.displayName
//            
//        self.tableView.deselectRow(at: indexPath, animated: true)
//        self.navigationController?.pushViewController(conversationVC, animated: true)
//        self.tableView.isUserInteractionEnabled = true
//
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return (section == 0) ? searchBar : nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return (section == 0) ? 44 : 0
//    }
//}
//
//
////MARK: - UISearchBarDelegate
//extension NewChatViewController: UISearchBarDelegate {
//    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        viewModel.filter(keyword: searchText)
//        tableView.reloadData()
//    }
//}
//
//
////MARK: - CreateGroupChatAddFriendProtocol
//extension NewChatViewController: CreateGroupChatAddFriendProtocol {
//    
//    func createGroupGetFriendInGroupList(friendsSelected: [FriendViewModel], groupName: String, groupImgUrl: String, friendsAdded: [FriendViewModel]) {
//        //TODO
////        let users = friendsSelected.flatMap({$0.friendLayerUserID})
//
//        guard ALDataNetworkConnection.checkDataNetworkAvailable() else { return }
//
//        //Server call
//
//        let newChannel = ALChannelService()
//        let membersList = NSMutableArray()
//        let _ = friendsSelected.map { membersList.add($0.friendUUID as Any) }
//
//        newChannel.createChannel(groupName, orClientChannelKey: nil, andMembersList: membersList, andImageLink: groupImgUrl, withCompletion: {
//            channel, error in
//            guard let alChannel = channel else {
//                print("error creating group", error.debugDescription)
//                return
//            }
//            print("group created")
//            let message = ALMessage()
//            message.groupId = alChannel.key
//            let list = NSMutableArray(object: message)
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTable"), object: list)
//
//            let viewModel = ConversationViewModel(contactId: nil, channelKey: alChannel.key)
//            let conversationVC = ConversationViewController()
//            conversationVC.viewModel = viewModel
//            conversationVC.title = groupName
//            self.navigationController?.pushViewController(conversationVC, animated: true)
//            self.tableView.isUserInteractionEnabled = true
//        })
//
////        if let conversation = ConversationListViewModel().createConversation(users: users) {
////            
////            conversation.setValue(groupName, forMetadataAtKeyPath: "group_name")
////            conversation.setValue(groupImgUrl, forMetadataAtKeyPath: "group_profile_url")
////            
////            let cache = RowHeighCache(identity: conversation.identifier.absoluteString)
////            let viewModel = ConversationViewModel(conversation: conversation, cache: cache)
////            
////            let hud = MBProgressHUD.showAdded(to: self.tableView, animated: true)
////            
////            viewModel.fetch(complete: { [weak self] (_) in
////                
////                hud.hide(animated: true)
////                
////                guard let strongSelf = self else {return}
////                
////                let conversationVC = ConversationViewController(viewModel: viewModel)
////                conversationVC.title = groupName
////                
////                strongSelf.navigationController?.pushViewController(conversationVC, animated: true)
////                strongSelf.tableView.isUserInteractionEnabled = true
////            })
////            
////            do {
////                try viewModel.send(createdConversation: conversation)
////            } catch {
////                Logger.error(message: "Fail to send 'create group' message", tag: .createConversation)
////            }
////        }
//    }
//
//}
