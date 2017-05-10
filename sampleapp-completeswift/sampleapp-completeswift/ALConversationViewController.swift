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

final class ALConversationViewController: ALBaseViewController {
    
    var viewModel: ALConversationViewModel!
    private var isFirstTime = true
    private var bottomConstraint: NSLayoutConstraint?
    private var isJustSent: Bool = false
    
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
        ALUserDefaultsHandler.setDebugLogsRequire(true)
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
                    weakSelf.tableView.reloadData()
                    weakSelf.tableView.scrollToBottom()
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
                break
                
            default:
                print("Not available")
            }
        }
    }
    
}

extension ALConversationViewController: ALConversationViewModelDelegate {
    func loadingFinished(error: Error?) {
        tableView.reloadData()
        tableView.scrollToBottom()
    }
    
    func messageUpdated() {
        tableView.reloadData()
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
        guard let message = viewModel.messageForRow(indexPath: indexPath) else {
            return UITableViewCell()
        }
        if message.isMyMessage {
            
            let cell: MyMessageCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.update(viewModel: message)
//            cell.update(chatBar: self.chatBar)
            return cell
            
        } else {
            let cell: FriendMessageCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.update(viewModel: message)
//            cell.update(chatBar: self.chatBar)
            return cell
        }
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
