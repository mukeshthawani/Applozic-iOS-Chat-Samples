//
//  FriendDatasource.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation


enum DatasourceState {
    case full, filtered
    
    init(isInUsed: Bool) {
        if isInUsed {
            self = .filtered
        } else {
            self = .full
        }
    }
}

protocol FriendDatasourceProtocol: class {
    func getDatasource(state: DatasourceState) -> [FriendViewModel]
    func count(state: DatasourceState) -> Int
    func getItem(atIndex: Int, state: DatasourceState) -> FriendViewModel?
    func updateItem(item: FriendViewModel, atIndex: Int, state: DatasourceState)
    func update(datasource: [FriendViewModel], state: DatasourceState)
}

final class FriendDatasource: FriendDatasourceProtocol {
    private var filteredList = [FriendViewModel]()
    private var friendList = [FriendViewModel]()
    
    func getDatasource(state: DatasourceState) -> [FriendViewModel] {
        switch state {
        case .full:
            return friendList
        case .filtered:
            return filteredList
        }
    }
    
    func count(state: DatasourceState) -> Int {
        switch state {
        case .full:
            return friendList.count
        case .filtered:
            return filteredList.count
        }
    }
    
    func getItem(atIndex: Int, state: DatasourceState) -> FriendViewModel? {
        let count = self.count(state: state)
        if count > atIndex {
            switch state {
            case .full:
                return friendList[atIndex]
            case .filtered:
                return filteredList[atIndex]
            }
        }
        return nil
    }
    
    func updateItem(item: FriendViewModel, atIndex: Int, state: DatasourceState) {
        let count = self.count(state: state)
        if count > atIndex {
            switch state {
            case .full:
                friendList[atIndex] = item
            case .filtered:
                filteredList[atIndex] = item
            }
        }
    }
    
    func update(datasource: [FriendViewModel], state: DatasourceState) {
        switch state {
        case .full:
            friendList = datasource
        case .filtered:
            filteredList = datasource
        }
    }
}
