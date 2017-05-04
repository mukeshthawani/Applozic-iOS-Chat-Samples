//
//  IdentityProtocol.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

protocol IdentityProtocol {
    
    var displayName: String {get}
    var displayPhoto: URL? {get}
    var userID: String {get}
    var layerID: String {get}
    var mood: String? {get}
    var emailAddress: String? {get}
    var mood_expired_at: NSNumber? {get}
}

protocol AccountProtocol {
    var ID: String {get}
    var layerID: String {get}
}

protocol AccountIdentityProtocol: IdentityProtocol {
    var identityOnboard: Bool {get}
    var isRequireVerification: Bool {get}
}
