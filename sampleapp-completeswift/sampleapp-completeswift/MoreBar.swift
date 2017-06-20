//
//  MoreBar.swift
//  Axiata
//
//  Created by Nitigron Ruengmontre on 12/15/2559 BE.
//  Copyright © 2559 Appsynth. All rights reserved.
//

import Foundation
import UIKit

final class MoreBar: UIView {
    
    enum ActionType {
        case emotion(UIButton)
        case location(UIButton)
        case attach(UIButton)
        case gift(UIButton)
        case bank(UIButton)
    }
    
    private var action: ((ActionType) -> ())?
    
    fileprivate let emotionButton: UIButton = {
        
        let bt = UIButton(type: .system)
        bt.tintColor = .mainRed()
        bt.setImage(UIImage(named: "icon_emoji"), for: .normal)
        return bt
    }()
    
    fileprivate let locationButton: UIButton = {
        
        let bt = UIButton(type: .system)
        bt.tintColor = .mainRed()
        bt.setImage(UIImage(named: "icon_send_location"), for: .normal)
        return bt
    }()
    
    fileprivate let attachButton: UIButton = {
        
        let bt = UIButton(type: .system)
        bt.tintColor = .mainRed()
        bt.setImage(UIImage(named: "icon_send_file"), for: .normal)
        return bt
    }()
    
    fileprivate let giftButton: UIButton = {
        
        let bt = UIButton(type: .system)
        bt.tintColor = .mainRed()
        bt.setImage(UIImage(named: "icon_send_gift"), for: .normal)
        return bt
    }()
    
    fileprivate let bankButton: UIButton = {
        
        let bt = UIButton(type: .system)
        bt.tintColor = .mainRed()
        bt.setImage(UIImage(named: "icon_send_money"), for: .normal)
        return bt
    }()
    
    
    fileprivate let bgView: TranslucentView = {
        let view = TranslucentView(frame: .zero)

        view.translucentAlpha = 0.65
        view.translucentStyle = UIBarStyle.default
        view.translucentTintColor = UIColor.init(netHex: 0xfce6e6)
        view.backgroundColor = UIColor.clear
        return view
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.clear
        
        emotionButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        attachButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        giftButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        bankButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapped(button: UIButton) {
        
        if button == locationButton {
//            Logger.debug(message: "Show Share Location")
            
            let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.shareLocation)
            
            guard let nav = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
           
            guard let shareLocationVC = nav.viewControllers.first as? ShareLocationViewController else { return }
            
            if let vc = presenterVC, let delegate = vc as? ShareLocationViewControllerDelegate {
                shareLocationVC.delegate = delegate
                presenterVC?.present(nav, animated: true, completion: {})
            }
            
        } else if button == giftButton {
            action?(.gift(button))
        } else if button == bankButton {
            action?(.bank(button))
        } else if button == attachButton {
            action?(.attach(button))
        } else if button == emotionButton {
            action?(.emotion(button))
        }
    }
    
    deinit {
        emotionButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        locationButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        attachButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        giftButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        bankButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        
        addViewsForAutolayout(views: [bgView, emotionButton,locationButton,attachButton,giftButton,bankButton])
        
        emotionButton.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        emotionButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        emotionButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        locationButton.topAnchor.constraint(equalTo: emotionButton.bottomAnchor).isActive = true
        locationButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        locationButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        attachButton.topAnchor.constraint(equalTo: locationButton.bottomAnchor).isActive = true
        attachButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        attachButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        attachButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        giftButton.topAnchor.constraint(equalTo: attachButton.bottomAnchor).isActive = true
        giftButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        giftButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        bankButton.topAnchor.constraint(equalTo: giftButton.bottomAnchor).isActive = true
        bankButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bankButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bankButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -4).isActive = true
        
        locationButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
        attachButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
        giftButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
        bankButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
        
        emotionButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        attachButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        giftButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        bankButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        bgView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bgView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bgView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bgView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
    }
    
    private weak var presenterVC: UIViewController?
    
    func setHandleAction(handleAction: ((ActionType) -> ())?) {
        self.action = handleAction
    }
    
    func setPresenterVC<T: UIViewController>(delegate: T) where T: ShareLocationViewControllerDelegate {
         presenterVC = delegate
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        var frame = bgView.frame
        frame.origin = .zero
        
        let radiusLayer = CAShapeLayer.init()
        
        let path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft, .bottomLeft] , cornerRadii: CGSize(width: 4, height: 4)).cgPath
        radiusLayer.frame = frame
        radiusLayer.path = path
        radiusLayer.masksToBounds = true
        
        bgView.layer.mask = radiusLayer
        bgView.layer.masksToBounds = true
        
    }
}
