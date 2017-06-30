//
//  MyVoiceCell.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

import UIKit
import Foundation
import Kingfisher
import AVFoundation

class MyVoiceCell: VoiceCell {
    
    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        let width = UIScreen.main.bounds.width
        
        contentView.addViewsForAutolayout(views: [stateView])
        
        soundPlayerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        soundPlayerView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 48).isActive = true
        soundPlayerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14).isActive = true
        soundPlayerView.widthAnchor.constraint(equalToConstant: width*0.48).isActive = true
        soundPlayerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).isActive = true
        
        bubbleView.backgroundColor = UIColor.hex8(Color.Background.grayF2.rawValue).withAlphaComponent(0.26)
        
        stateView.widthAnchor.constraint(equalToConstant: 17.0).isActive = true
        stateView.heightAnchor.constraint(equalToConstant: 9.0).isActive = true
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.rightAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: -2.0).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: stateView.leftAnchor, constant: -2.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 0).isActive = true
    }
    
    override func update(viewModel: MessageViewModel) {
        super.update(viewModel: viewModel)
        
        if viewModel.isAllRead {
            stateView.image = UIImage(named: "read_state_3")
        } else if viewModel.isAllReceived {
            stateView.image = UIImage(named: "read_state_2")
        } else if viewModel.isSent {
            stateView.image = UIImage(named: "read_state_1")
        } else {
            stateView.image = UIImage(named: "seen_state_0")
        }
        
    }
    
    override class func bottomPadding() -> CGFloat {
        return 6
    }
    
}
