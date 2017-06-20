//
//  NewChatViewModel.swift
//  Axiata
//
//  Created by appsynth on 2/3/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import Foundation


final class NewChatViewModel {
    
//    var friendList = [IdentityProtocol]()    // For UI presentation
//    var bufferFriendList = [IdentityProtocol]() {
//        didSet {
//            self.friendList = bufferFriendList
//        }
//    }
//    
//    let friendDataService: FriendDataService
//    
//    init(friendDataService: FriendDataService) {
//        self.friendDataService = friendDataService
//    }
//    
//    func filter(keyword: String) {
//        if keyword.isEmpty {
//            self.friendList = self.bufferFriendList
//        } else {
//            self.friendList = self.bufferFriendList.filter({$0.displayName.lowercased().contains(keyword.lowercased())})
//        }
//    }
//    
//    func getAllFriends(completion: @escaping () -> ()) {
//        friendDataService.fetch { [weak self] (friends) in
//            self?.bufferFriendList = friends
//            completion()
//        }
//        
//    }
//    
//    func numberOfSection() -> Int {
//        return 2
//    }
//    
//    func numberOfRowsInSection(section: Int) -> Int {
//        
//        return self.friendList.count
//    }
//    
//    func friendForRow(indexPath: IndexPath) -> IdentityProtocol {
//        return self.friendList[indexPath.row]
//    }
//    
//    // Internal class
//    final class CreateGroup: IdentityProtocol {
//        
//        var mood_expired_at: NSNumber?  = 0
//        var displayName: String = "Create Group"
//        var mood: String? = ""
//        var layerID: String = ""
//        var userID: String = ""
//        var displayPhoto: URL? = nil
//        var emailAddress: String? {return ""}
//    }
//    
//    func createGroupCell() -> IdentityProtocol {
//        return CreateGroup()
//    }
}
