//
//  FriendPhotoPortalCell.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

// MARK: - FriendPhotoPortalCell
final class FriendPhotoPortalCell: FriendPhotoCell {
    
    override func setupViews() {
        super.setupViews()
        let width = UIScreen.main.bounds.width
        photoView.widthAnchor.constraint(equalToConstant: width*0.48).isActive = true
    }
}
