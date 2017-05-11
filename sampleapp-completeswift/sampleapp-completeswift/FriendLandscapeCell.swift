
//  FriendLandscapeCell.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 07/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

// MARK: - FriendPhotoLandscapeCell
final class FriendPhotoLandscapeCell: FriendPhotoCell {
    
    override func setupViews() {
        super.setupViews()
        let width = UIScreen.main.bounds.width
        photoView.widthAnchor.constraint(equalToConstant: width*0.64).isActive = true
    }
}
