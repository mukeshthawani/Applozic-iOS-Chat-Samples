//
//  CreateGroupViewModel.swift
//  Axiata
//
//  Created by appsynth on 3/7/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import Foundation


class CreateGroupViewModel {
    
    var groupName: String = ""
    var originalGroupName: String = ""
    
    func isAddParticipantButtonEnabled() -> Bool {
        let name = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty
    }
    
    init(groupName name: String) {
        groupName = name
        originalGroupName = name
    }
}
