////
////  LocationCell.swift
////  sampleapp-completeswift
////
////  Created by Mukesh Thawani on 07/05/17.
////  Copyright © 2017 Applozic. All rights reserved.
////
//
//import UIKit
//import Kingfisher
//
//protocol LocationCellDelegate: class {
//    func displayLocation(location:LocationPreviewViewModel)
//}
//
//class LocationCell: ChatBaseCell<MessageViewModel> {
//    
//    weak var delegate:LocationCellDelegate?
//    
//    // MARK: - Declare Variables or Types
//    // MARK: Environment in chat
//    internal var timeLabel: UILabel = {
//        let label = UILabel()
//        return label
//    }()
//    
//    internal var bubbleView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .black
//        view.layer.cornerRadius = 12
//        view.clipsToBounds = true
//        view.isUserInteractionEnabled = true
//        return view
//    }()
//    
//    private var frontView: UIView = {
//        let view = UIView()
//        view.alpha = 1.0
//        view.backgroundColor = .clear
//        view.isUserInteractionEnabled = true
//        return view
//    }()
//    
//    private lazy var tapGesture: UITapGestureRecognizer = {
//        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(withTapGesture:)))
//        tapGesture.numberOfTapsRequired = 1
//        return tapGesture
//    }()
//    
//    private var topViewController: UIViewController? {
//        guard var topViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
//        
//        while let presentedViewController = topViewController.presentedViewController {
//            topViewController = presentedViewController
//        }
//        
//        return topViewController
//    }
//    
//    // MARK: Content in chat
//    private var tempLocation: Geocode?
//    
//    private var locationImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.clipsToBounds = true
//        imageView.backgroundColor = .clear
//        imageView.contentMode = .scaleAspectFill
//        return imageView
//    }()
//    
//    private var addressLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 1
//        label.setFont(font: .normal(size: 14.0))
//        label.setBackgroundColor(color: .none)
//        return label
//    }()
//    
//    // MARK: - Lifecycle
//    override func setupViews() {
//        super.setupViews()
//        
//        // setup view with gesture
//        frontView.addGestureRecognizer(tapGesture)
//        frontView.addGestureRecognizer(longPressGesture)
//        
//        // add view to contenview and setup constraint
//        contentView.addViewsForAutolayout(views: [bubbleView, timeLabel])
//        
//        bubbleView.addViewsForAutolayout(views: [frontView, locationImageView, addressLabel])
//        bubbleView.bringSubview(toFront: frontView)
//        
//        frontView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 0.0).isActive = true
//        frontView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 0.0).isActive = true
//        frontView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 0.0).isActive = true
//        frontView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 0.0).isActive = true
//        
//        locationImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 0.0).isActive = true
//        locationImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 0.0).isActive = true
//        locationImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 0.0).isActive = true
//        locationImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.64).isActive = true
//        
//        addressLabel.topAnchor.constraint(equalTo: locationImageView.bottomAnchor, constant: 4.0).isActive = true
//        addressLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -4.0).isActive = true
//        addressLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8.0).isActive = true
//        addressLabel.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8.0).isActive = true
//        addressLabel.heightAnchor.constraint(equalToConstant: 18.0).isActive = true
//    }
//    
//    override func setupStyle() {
//        super.setupStyle()
//        timeLabel.setStyle(style: MessageStyle.time)
//    }
//    
//    override func update(viewModel: MessageViewModel) {
//        super.update(viewModel: viewModel)
//        
//        // timeLable
//        timeLabel.text = viewModel.time
//        
//        // addressLabel
//        if let geocode = viewModel.geocode {
//            addressLabel.text = geocode.formattedAddress
//        }
//        
//        // locationImageView
//        locationImageView.image = nil
//        
//        if let thumbnailMessagePart = viewModel.thumbnailMessagePart {
//            if let data = thumbnailMessagePart.data {
//                locationImageView.image = UIImage(data: data)
//            }
//        }
//    }
//    
//    override class func rowHeigh(viewModel: MessageViewModel,width: CGFloat) -> CGFloat {
//        let heigh: CGFloat = ceil((width * 0.64) / viewModel.ratio)
//        return heigh + 26.0
//    }
//    
//    // MARK: - Method of class
//    func setDelegate(locDelegate:LocationCellDelegate) {
//        delegate = locDelegate
//    }
//    
//    func handleTap(withTapGesture gesture: UITapGestureRecognizer) {
//        if let geocode = viewModel?.geocode ,gesture.state == .ended {
//            tempLocation = geocode
//            openMap(withLocation: geocode, completion: nil)
//        }
//    }
//    
//    func openMap(withLocation geocode: Geocode, completion: ((_ isSuccess: Bool) -> Swift.Void)? = nil) {
//        if let locDelegate = delegate , locationPreviewViewModel().isReady{
//            locDelegate.displayLocation(location: locationPreviewViewModel())
//        }
//    }
//    
//    // MARK: - PreviewLocationViewControllerDelegate
//    func locationPreviewViewModel() -> LocationPreviewViewModel {
//        guard let loc = tempLocation else {
//            return LocationPreviewViewModel(addressText: SystemMessage.UIError.unspecifiedLocation)
//        }
//        return LocationPreviewViewModel(geocode:loc)
//    }
//    
//}