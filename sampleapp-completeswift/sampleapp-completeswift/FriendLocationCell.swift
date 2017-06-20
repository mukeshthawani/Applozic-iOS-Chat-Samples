//
//  FriendLocationCell.swift
//  Axiata
//
//  Created by Mo on 3/24/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import UIKit
import Kingfisher

final class FriendLocationCell: LocationCell {

    // MARK: - Declare Variables or Types
    // MARK: Environment in chat
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
    
    // MARK: - Lifecycle
    override func setupViews() {
        super.setupViews()
        
        bubbleView.backgroundColor = UIColor.background(.grayF2)
        
        // add view to contenview and setup constraint
        contentView.addViewsForAutolayout(views: [avatarImageView,nameLabel])
        
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 57.0).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -56.0).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 16.0).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18.0).isActive = true
        avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0.0).isActive = true
        avatarImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 9.0).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 37.0).isActive = true
        avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor).isActive = true
        
        bubbleView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6.0).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.0).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 10.0).isActive = true
        
        timeLabel.leftAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 2.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2.0).isActive = true
    }
    
    override func setupStyle() {
        super.setupStyle()
        nameLabel.setStyle(style: MessageStyle.displayName)
    }
    
    override func update(viewModel: MessageViewModel) {
        super.update(viewModel: viewModel)
        
        nameLabel.text = viewModel.displayName
        
        let placeHolder = UIImage(named: "placeholder")
        
        if let url = viewModel.avatarURL {
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            avatarImageView.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            avatarImageView.image = placeHolder
        }
    }
    
    override class func rowHeigh(viewModel: MessageViewModel,width: CGFloat) -> CGFloat {
        return super.rowHeigh(viewModel: viewModel, width: width) + 34.0
    }
    
}
