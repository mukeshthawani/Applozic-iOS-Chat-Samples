//
//  FriendPhotoCell.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 07/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Kingfisher

// MARK: - FriendPhotoCell
class FriendPhotoCell: PhotoCell {
    
    private var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 18.5
        layer.backgroundColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
        return imv
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    override class func topPadding() -> CGFloat {
        return 28
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        nameLabel.setStyle(style: MessageStyle.displayName)
    }
    
    override func setupViews() {
        super.setupViews()
        
        contentView.addViewsForAutolayout(views: [avatarImageView,nameLabel])
        
        bubbleView.backgroundColor = UIColor.hex8(Color.Background.grayF2.rawValue).withAlphaComponent(0.26)
        
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 57).isActive = true
        
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -56).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: photoView.topAnchor, constant: -6).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18).isActive = true
        avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0).isActive = true
        
        avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 9).isActive = true
        avatarImageView.trailingAnchor.constraint(equalTo: photoView.leadingAnchor, constant: -10).isActive = true
        
        avatarImageView.heightAnchor.constraint(equalToConstant: 37).isActive = true
        avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor).isActive = true
        
        photoView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -56).isActive = true
        photoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        
        timeLabel.leftAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 2).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
        
        fileSizeLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 0).isActive = true
    }
    
    override func update(viewModel: MessageViewModel) {
        super.update(viewModel: viewModel)
        
        nameLabel.text = viewModel.displayName
        
        let placeHolder = UIImage(named: "placeholder")
        
        if let url = viewModel.avatarURL {
            
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            self.avatarImageView.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            
            self.avatarImageView.image = placeHolder
        }
        
        
        
    }
}
