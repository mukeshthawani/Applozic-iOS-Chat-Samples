//
//  AlertInformation.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation


struct AlertText {
    struct Title {
        static let Discard = "Discard change"
    }
    
    struct Message {
        static let Discard = "If you go back now, your change will be discarded"
    }
}

enum AlertInformation {
    case discardChange
    
    var title: String {
        get {
            switch self {
            case .discardChange:
                return AlertText.Title.Discard
            }
        }
    }
    
    var message: String {
        get {
            switch self {
            case .discardChange:
                return AlertText.Message.Discard
            }
        }
    }
}
