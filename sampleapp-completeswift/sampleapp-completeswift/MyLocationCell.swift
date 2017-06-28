//
//  MyLocationCell.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

final class MyLocationCell: LocationCell {
    
    // MARK: - Declare Variables or Types
    // MARK: Environment in chat
    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()
    
    // MARK: - Lifecycle
    override func setupViews() {
        super.setupViews()
        
        bubbleView.backgroundColor = UIColor.background(.redC0)
        
        // add view to contenview and setup constraint
        contentView.addViewsForAutolayout(views: [stateView])
        
        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6.0).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -14.0).isActive = true
        
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.rightAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: -2.0).isActive = true
        stateView.widthAnchor.constraint(equalToConstant: 17.0).isActive = true
        stateView.heightAnchor.constraint(equalToConstant: 9.0).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: stateView.leftAnchor, constant: -2.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
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
    
    override class func rowHeigh(viewModel: MessageViewModel,width: CGFloat) -> CGFloat {
        return super.rowHeigh(viewModel: viewModel, width: width) + 12.0
    }
    
}
