//
//  PhotoCell.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 08/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import MBProgressHUD


// MARK: - PhotoCell
class PhotoCell: ChatBaseCell<MessageViewModel> {
    
    var photoView: UIImageView = {
        let mv = UIImageView()
        mv.backgroundColor = .clear
        mv.contentMode = .scaleAspectFill
        mv.clipsToBounds = true
        mv.layer.cornerRadius = 12
        return mv
    }()
    
    var timeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()
    
    var fileSizeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()
    
    fileprivate var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        return button
    }()
    
    var bubbleView: UIView = {
        let bv = UIView()
        bv.backgroundColor = .gray
        bv.layer.cornerRadius = 12
        bv.isUserInteractionEnabled = false
        return bv
    }()
    
    class func topPadding() -> CGFloat {
        return 12
    }
    
    class func bottomPadding() -> CGFloat {
        return 16
    }
    
    override class func rowHeigh(viewModel: MessageViewModel,width: CGFloat) -> CGFloat {
        
        let heigh: CGFloat
        
        if viewModel.ratio < 1 {
            heigh = viewModel.ratio == 0 ? (width*0.48) : ceil((width*0.48)/viewModel.ratio)
        } else {
            heigh = ceil((width*0.64)/viewModel.ratio)
        }
        
        return topPadding()+heigh+bottomPadding()
    }
    
    override func update(viewModel: MessageViewModel) {
        
        self.viewModel = viewModel
        
        self.photoView.image = UIImage()
        
//        if let data = viewModel.thumbnailMessagePart?.data {
//            photoView.image = UIImage(data: data)
//        } else if let dataURL = viewModel.thumbnailMessagePart?.fileURl {
//            
//            do {
//                
//                let data = try Data.init(contentsOf: dataURL)
//                photoView.image = UIImage.init(data: data)
//                
//            } catch {
////                Logger.debug(message: "load image fail")
//            }
//            
//        }
//        
        var url: URL? = nil
        if let imageURL = viewModel.imageURL {
            url = imageURL
        } else if let imageUrl = viewModel.thumbnailURL {
            url = imageUrl
        }
        photoView.kf.indicatorType = .activity
        photoView.kf.setImage(with: url)
        let fileString = ByteCountFormatter.string(fromByteCount: viewModel.size, countStyle: .file)
        
        timeLabel.text   = viewModel.time
//                        fileSizeLabel.text = "Downloaded"
//        if !viewModel.isMyMessage {
//            if let originalMessagePart = viewModel.messagePart, originalMessagePart.data != nil {
//                fileSizeLabel.text = "Downloaded"
//            } else {
//                fileSizeLabel.text = "File size: \(fileString)"
//            }
//        }
        
    }
    
    func actionTapped(button: UIButton) {
//        button.isEnabled = false
//        
//        let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.previewImage)
//        
//        guard let messagePart = viewModel?.messagePart,
//            let nav = storyboard.instantiateInitialViewController() as? UINavigationController,
//            let vc = nav.viewControllers.first as? PreviewImageViewController else {
//                
//                button.isEnabled = true
//                return
//        }
//        
//        vc.viewModel = PreviewImageViewModel(messagePart: messagePart)
//        UIViewController.topViewController()?.present(nav, animated: true, completion: {
//            button.isEnabled = true
//        })
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        timeLabel.setStyle(style: MessageStyle.time)
        fileSizeLabel.setStyle(style: MessageStyle.time)
    }
    
    override func setupViews() {
        super.setupViews()
        
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        
        contentView.addViewsForAutolayout(views: [photoView,bubbleView,actionButton,timeLabel,fileSizeLabel])
        contentView.bringSubview(toFront: photoView)
        contentView.bringSubview(toFront: actionButton)
        
        bubbleView.topAnchor.constraint(equalTo: photoView.topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: photoView.bottomAnchor).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: photoView.leftAnchor).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: photoView.rightAnchor).isActive = true
        
        actionButton.topAnchor.constraint(equalTo: photoView.topAnchor).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: photoView.bottomAnchor).isActive = true
        actionButton.leftAnchor.constraint(equalTo: photoView.leftAnchor).isActive = true
        actionButton.rightAnchor.constraint(equalTo: photoView.rightAnchor).isActive = true
        
        fileSizeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
    }
    
    deinit {
        actionButton.removeTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }
    
}
