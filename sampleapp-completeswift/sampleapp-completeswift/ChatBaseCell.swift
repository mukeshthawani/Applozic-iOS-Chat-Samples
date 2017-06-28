//
//  ChatBaseCell.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

class ChatBaseCell<T>: BaseCell<T> {
    
    fileprivate weak var chatBar: ChatBar?
    
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        return UILongPressGestureRecognizer(target: self, action: #selector(showMenuController(withLongPress:)))
    }()
    
    func update(chatBar: ChatBar) {
        self.chatBar = chatBar
    }
    
    @objc func menuWillShow(_ sender: Any) {
        NotificationCenter.default.removeObserver(self, name: .UIMenuControllerWillShowMenu, object: nil)
    }
    
    @objc func menuWillHide(_ sender: Any) {
        NotificationCenter.default.removeObserver(self, name: .UIMenuControllerWillHideMenu, object: nil)
        
        if let chatBar = self.chatBar {
            chatBar.textView.overrideNextResponder = nil
        }
    }
    
    @objc func showMenuController(withLongPress sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            NotificationCenter.default.addObserver(self, selector: #selector(menuWillShow(_:)), name: .UIMenuControllerWillShowMenu, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(menuWillHide(_:)), name: .UIMenuControllerWillHideMenu, object: nil)
            
            if let chatBar = self.chatBar, chatBar.textView.isFirstResponder {
                chatBar.textView.overrideNextResponder = self.contentView
            } else {
                self.canBecomeFirstResponder
            }
            
            let sharedMenuController: UIMenuController = UIMenuController.shared
            var menus: [UIMenuItem] = []
            
            if let menuItem = self as? CopyMenuItemProtocol {
                let menu = UIMenuItem(title: menuItem.title, action: menuItem.selector)
                menus.append(menu)
            }
            
            if let view = sender.view {
                let point = sender.location(in: view)
                let rect = CGRect.init(x: point.x, y: point.y, width: 1.0, height: 1.0)
                
                sharedMenuController.setTargetRect(rect, in: view)
            }
            
            sharedMenuController.menuItems = menus
            sharedMenuController.setMenuVisible(true, animated: true)
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch self {
        case let menuItem as CopyMenuItemProtocol where action == menuItem.selector:
            return true
        default:
            return false
        }
    }
}

// MARK: - CopyMenuItemProtocol
@objc protocol CopyMenuItemProtocol {
    func menuCopy(_ sender: Any)
}

extension CopyMenuItemProtocol {
    var title: String {
        return "Copy"
    }
    var selector: Selector {
        return #selector(menuCopy(_:))
    }
}
