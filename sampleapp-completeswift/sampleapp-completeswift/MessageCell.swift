//
//  MessageCell.swift
//  Axiata
//
//  Created by Nitigron Ruengmontre on 12/7/2559 BE.
//  Copyright © 2559 Appsynth. All rights reserved.
//

import Foundation
import UIKit
//import LayerKit
import Kingfisher

// MARK: - MessageType
enum MessageType {
    case text
    case photo
    case voice
    case location
    case information
}

// MARK: - MessageViewModel
protocol MessageViewModel {
    var message: String? { get }
    var isMyMessage: Bool { get }
    var messageType: MessageType { get }
    var identifier: String { get }
    var date: Date { get }
    var time: String? { get }
    var avatarURL: URL? { get }
    var displayName: String? { get }
    var contactId: String? { get }
    var channelKey: NSNumber? { get }
    var conversationId: NSNumber? { get }
    var isSent: Bool { get }
    var isAllReceived: Bool { get }
    var isAllRead: Bool { get }
    var ratio: CGFloat { get }
    var size: Int64 { get }
    var thumbnailURL: URL? { get }
    var imageURL: URL? { get }
    var filePath: String? { get }
    var geocode: Geocode? { get }
    var voiceData: Data? { get set }
    var voiceTotalDuration: CGFloat { get set }
    var voiceCurrentDuration: CGFloat { get set }
    var voiceCurrentState: VoiceCellState { get set }
}

// MARK: - FriendMessageCell
final class FriendMessageCell: MessageCell {

    private var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 18.5
        layer.masksToBounds = true
        return imv
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isOpaque = true
        return label
    }()

    override func setupViews() {
        super.setupViews()

        contentView.addViewsForAutolayout(views: [avatarImageView,nameLabel])

        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 57).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -57).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: messageView.topAnchor, constant: -10).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18).isActive = true
        avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0).isActive = true

        avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 9).isActive = true

        avatarImageView.trailingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -18).isActive = true

        avatarImageView.heightAnchor.constraint(equalToConstant: 37).isActive = true
        avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor).isActive = true


        messageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -57).isActive = true

        messageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -1 * FriendMessageCell.bottomPadding()).isActive = true

        timeLabel.leftAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 10).isActive = true

        bubbleView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: -4).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 4).isActive = true

        bubbleView.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: -13).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: messageView.rightAnchor, constant: 5).isActive = true

        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true

        bubbleView.image = UIImage.init(named: "chat_bubble_grey")
    }

    override func setupStyle() {
        super.setupStyle()

        nameLabel.setStyle(style: MessageStyle.displayName)
    }

    override func update(viewModel: MessageViewModel) {
        super.update(viewModel: viewModel)

        let placeHolder = UIImage(named: "placeholder")

        if let url = viewModel.avatarURL {

            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            self.avatarImageView.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
        } else {

            self.avatarImageView.image = placeHolder
        }

        nameLabel.text = viewModel.displayName
    }

    override class func leftPadding() -> CGFloat {
        return 64//9+37+18
    }

    override class func rightPadding() -> CGFloat {
        return 57
    }

    override class func topPadding() -> CGFloat {
        return 32//6+16+10
    }

    override class func bottomPadding() -> CGFloat {
        return 6
    }

    // MARK: - ChatMenuCell
    override func menuWillShow(_ sender: Any) {
        super.menuWillShow(sender)
        self.bubbleView.image = UIImage.init(named: "chat_bubble_grey_hover")
    }

    override func menuWillHide(_ sender: Any) {
        super.menuWillHide(sender)
        self.bubbleView.image = UIImage.init(named: "chat_bubble_grey")
    }

    override class func rowHeigh(viewModel: MessageViewModel,width: CGFloat) -> CGFloat {

        let minimumHeigh: CGFloat = 55.0
        let totalRowHeigh = super.rowHeigh(viewModel: viewModel, width: width)
        return totalRowHeigh < minimumHeigh ? minimumHeigh : totalRowHeigh
    }
}


// MARK: - FriendMessageCell
final class MyMessageCell: MessageCell {

    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    override func setupViews() {
        super.setupViews()

        contentView.addViewsForAutolayout(views: [stateView])

        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: MessageCell.topPadding()).isActive = true
        messageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: MessageCell.rightPadding()).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1*MessageCell.leftPadding()).isActive = true
        messageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -1 * MyMessageCell.bottomPadding()).isActive = true

        bubbleView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: -4).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 4).isActive = true

        bubbleView.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: -5).isActive = true

        bubbleView.rightAnchor.constraint(equalTo: messageView.rightAnchor, constant: 10).isActive = true

        stateView.widthAnchor.constraint(equalToConstant: 17.0).isActive = true
        stateView.heightAnchor.constraint(equalToConstant: 9.0).isActive = true
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.rightAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: -2.0).isActive = true

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

    // MARK: - ChatMenuCell
    override func menuWillShow(_ sender: Any) {
        super.menuWillShow(sender)
        self.bubbleView.image = UIImage.init(named: "chat_bubble_red_hover")
    }

    override func menuWillHide(_ sender: Any) {
        super.menuWillHide(sender)
        self.bubbleView.image = UIImage.init(named: "chat_bubble_red")
    }
}

class MessageCell: ChatBaseCell<MessageViewModel>, CopyMenuItemProtocol{

    fileprivate lazy var messageView: UILabel = {
        let lb = UILabel.init(frame: .zero)
        lb.isUserInteractionEnabled = true
        lb.numberOfLines = 0
        lb.lineBreakMode = .byWordWrapping
        return lb
    }()

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate var bubbleView: UIImageView = {
        let bv = UIImageView()
        bv.image = UIImage.init(named: "chat_bubble_red")
        bv.isUserInteractionEnabled = false
        bv.isOpaque = true
        return bv
    }()

    override func update(viewModel: MessageViewModel) {
        self.viewModel = viewModel

        self.messageView.attributedText = nil
        self.messageView.text = nil
        if let message = viewModel.message {
            self.messageView.text = viewModel.message
        }


        self.timeLabel.text   = viewModel.time
    }

    override func setupViews() {
        super.setupViews()

        contentView.addViewsForAutolayout(views: [messageView,bubbleView,timeLabel])
        contentView.bringSubview(toFront: messageView)
        /*
         let tapOnLabelGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapOnLabel(gesture:)))
         tapOnLabelGesture.numberOfTapsRequired = 1
         messageView.addGestureRecognizer(tapOnLabelGesture)
         messageView.addGestureRecognizer(longPressGesture)
         */
    }

    override func setupStyle() {
        super.setupStyle()

        timeLabel.setStyle(style: MessageStyle.time)
        messageView.setStyle(style: MessageStyle.message)

    }

    class func leftPadding() -> CGFloat {
        return 16
    }

    class func rightPadding() -> CGFloat {
        return 65
    }

    class func topPadding() -> CGFloat {
        return 10
    }

    class func bottomPadding() -> CGFloat {
        return 10
    }

    override class func rowHeigh(viewModel: MessageViewModel,width: CGFloat) -> CGFloat {

        var messageHeigh: CGFloat = 0

        if let message = viewModel.message {

            let widthNoPadding = width - leftPadding() - rightPadding()
            let maxSize = CGSize.init(width: widthNoPadding, height: CGFloat.greatestFiniteMagnitude)

            let font = Font.normal(size: 14).font()
            let color = UIColor.color(MessageStyle.message.color)

            let style = NSMutableParagraphStyle.init()
            style.lineBreakMode = .byWordWrapping
            style.headIndent = 0
            style.tailIndent = 0
            style.firstLineHeadIndent = 0
            style.minimumLineHeight = 17
            style.maximumLineHeight = 17

            let attributes: [String : Any] = [NSFontAttributeName: font,
                                              NSForegroundColorAttributeName: color,
                                              NSParagraphStyleAttributeName: style
            ]

            let size = message.boundingRect(with: maxSize, options: [NSStringDrawingOptions.usesFontLeading, NSStringDrawingOptions.usesLineFragmentOrigin],attributes: attributes, context: nil)

            messageHeigh = ceil(size.height)

        }

        return topPadding()+messageHeigh+bottomPadding()
    }

    func menuCopy(_ sender: Any) {
        UIPasteboard.general.string = self.viewModel?.message ?? ""
    }
}
