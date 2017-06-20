//
//  ChatCell.swift
//  Axiata
//
//  Created by Nitigron Ruengmontre on 12/7/2559 BE.
//  Copyright © 2559 Appsynth. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import MGSwipeTableCell

protocol ChatViewModelProtocol {
    var avatar: URL? { get }
    var avatarImage: UIImage? { get }
    var avatarGroupImageUrl: String? { get }
    var name: String { get }
    var groupName: String { get }
    var theLastMessage: String? { get }
    var hasUnreadMessages: Bool { get }
    var totalNumberOfUnreadMessages: UInt { get }
    var isGroupChat: Bool { get }
    var contactId: String? { get }
    var channelKey: NSNumber? { get }
}

enum ChatCellAction {
    case delete
    case favorite
    case store
    case call
    case mute
}

protocol ChatCellDelegate: class {
    func chatCell(cell: ChatCell, action: ChatCellAction, viewModel: ChatViewModelProtocol)
}

final class ChatCell: MGSwipeTableCell {

    private var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 22.5
        layer.backgroundColor = UIColor.clear.cgColor
        layer.masksToBounds = true
        return imv
    }()

    private var statusBall: UIView = {
        let view = UIView()
        let layer = view.layer

        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.5
        layer.cornerRadius = 8

        layer.backgroundColor = UIColor.mainRed().cgColor
        layer.masksToBounds = true
        view.clipsToBounds = true

        let mask = CAShapeLayer.init()
        mask.path = UIBezierPath.init(roundedRect: CGRect.init(x: 0.5, y: 0.5, width: 15, height: 15), cornerRadius: 7.5).cgPath

        layer.mask = mask

        return view
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = Font.bold(size: 14.0).font()
        label.textColor = .text(.black00)
        return label
    }()

    private var locationLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = Font.normal(size: 14.0).font()
        label.textColor = UIColor(netHex: 0x9B9B9B)
        return label
    }()

    private var moodLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = Font.italic(size: 14.0).font()
        label.textColor = UIColor(netHex: 0xE00909)
        return label
    }()

    private var lineView: UIView = {
        let view = UIView()
        let layer = view.layer
        view.backgroundColor = UIColor.init(red: 200.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 0.33)
        return view
    }()

    private lazy var voipButton: UIButton = {
        let bt = UIButton(type: .custom)
        bt.setImage(UIImage(named: "icon_menu_dial_on"), for: .normal)
        bt.setImage(UIImage(named: "icon_call_disable"), for: .disabled)
        bt.addTarget(self, action: #selector(callTapped(button:)), for: .touchUpInside)
        return bt
    }()

    private lazy var favoriteButton: UIButton = {
        let bt = UIButton(type: .custom)
        bt.setImage(UIImage(named: "icon_favorite"), for: .normal)
        bt.setImage(UIImage(named: "icon_favorite_active"), for: .highlighted)
        bt.setImage(UIImage(named: "icon_favorite_active"), for: .selected)
        bt.addTarget(self, action: #selector(favoriteTapped(button:)), for: UIControlEvents.touchUpInside)
        return bt
    }()

    // MARK: BadgeNumber
    private lazy var badgeNumberView: UIView = {
        let view = UIView(frame: .zero)
        view.setBackgroundColor(color: .main)
        return view
    }()

    private lazy var badgeNumberLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "0"
        label.textAlignment = .center
        label.setTextColor(color: .white)
        label.setFont(font: .normal(size: 9.0))

        return label
    }()

    weak var chatCellDelegate: ChatCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    deinit {
        voipButton.removeTarget(self, action:  #selector(callTapped(button:)), for: .touchUpInside)
        //favoriteButton.removeTarget(self, action:  #selector(favoriteTapped(button:)), for: .touchUpInside)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        guard let viewModel = viewModel else {
            return
        }

        let hasUnreadMessages = viewModel.hasUnreadMessages
        let ballColor = hasUnreadMessages == true ? UIColor.green.cgColor : UIColor.mainRed().cgColor
        statusBall.layer.backgroundColor = ballColor

        lineView.backgroundColor = UIColor(netHex: 0xF1F1F1)

        backgroundColor = highlighted ? UIColor.init(netHex: 0xECECEC) : UIColor.white
        contentView.backgroundColor = backgroundColor

        // set backgroundColor of badgeNumber
        badgeNumberView.setBackgroundColor(color: .main)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        guard let viewModel = viewModel else {
            return
        }

        let hasUnreadMessages = viewModel.hasUnreadMessages
        let ballColor = hasUnreadMessages == true ? UIColor.green.cgColor : UIColor.mainRed().cgColor
        statusBall.layer.backgroundColor = ballColor

        lineView.backgroundColor = UIColor(netHex: 0xF1F1F1)

        backgroundColor = selected ? UIColor.init(netHex: 0xECECEC) : UIColor.white
        contentView.backgroundColor = backgroundColor

        // set backgroundColor of badgeNumber
        badgeNumberView.setBackgroundColor(color: .main)
    }

    var viewModel: ChatViewModelProtocol?

    func update(viewModel: ChatViewModelProtocol, identity: IdentityProtocol?) {

        self.viewModel = viewModel
        let placeHolder = UIImage(named: "placeholder")

        if let avatarImage = viewModel.avatarImage {
            if let imgStr = viewModel.avatarGroupImageUrl,let imgURL = URL.init(string: imgStr) {
                let resource = ImageResource(downloadURL: imgURL, cacheKey: imgStr)
                avatarImageView.kf.setImage(with: resource, placeholder: avatarImage, options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                avatarImageView.image = avatarImage
            }

        }else if let avatar = viewModel.avatar {
            let resource = ImageResource(downloadURL: avatar, cacheKey: avatar.absoluteString)
            avatarImageView.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            self.avatarImageView.image = placeHolder
        }

        let name = viewModel.isGroupChat ? viewModel.groupName:viewModel.name
        let hasUnreadMessages = viewModel.hasUnreadMessages
        let logText = "\(name) [\(hasUnreadMessages)]"
//        Logger.verbose(message: logText, tag: LoggerTag.hasUnreadMessagesInConversation)
        let ballColor = hasUnreadMessages == true ? UIColor.green.cgColor : UIColor.mainRed().cgColor
        statusBall.layer.backgroundColor = ballColor
        nameLabel.text = name
        locationLabel.text = viewModel.theLastMessage

        if let identity = identity, let mood = identity.mood, !mood.isEmpty,!viewModel.isGroupChat, let expireDate = identity.mood_expired_at {

            let currentDate = Date()
            let expireDate = Date(timeIntervalSince1970: TimeInterval(expireDate))
            if currentDate < expireDate {
                moodLabel.text = mood
            } else {
                moodLabel.text = ""
            }

        } else {
            self.moodLabel.text = ""
        }

        let deleteButton = MGSwipeButton.init(type: .system)
        deleteButton.backgroundColor = UIColor.mainRed()
        deleteButton.setImage(UIImage(named: "icon_delete_white"), for: .normal)
        deleteButton.setImage(UIImage(named: "icon_delete_white"), for: .highlighted)
        deleteButton.setImage(UIImage(named: "icon_delete_white"), for: .selected)
        deleteButton.tintColor = .white
        deleteButton.frame = CGRect.init(x: 0, y: 0, width: 69, height: 69)
        deleteButton.callback = { [weak self] (buttnon) in

            guard let strongSelf = self else {return true}
            guard let viewModel = strongSelf.viewModel else {return true}

            strongSelf.chatCellDelegate?.chatCell(cell: strongSelf, action: .delete, viewModel: viewModel)

            return true
        }

        let muteButton = MGSwipeButton.init(type: .custom)
        muteButton.backgroundColor = UIColor.init(netHex: 0x999999)
        muteButton.setImage(UIImage(named: "icon_mute_inactive"), for: .normal)
        muteButton.setImage(UIImage(named: "icon_mute_active"), for: .selected)
        muteButton.frame = CGRect.init(x: 0, y: 0, width: 69, height: 69)
        muteButton.callback = { [weak self] (buttnon) in

            guard let strongSelf = self else {return true}
            guard let viewModel = strongSelf.viewModel else {return true}

            strongSelf.chatCellDelegate?.chatCell(cell: strongSelf, action: .mute, viewModel: viewModel)

            return true
        }

        //disable for now, might have to add them later AX-399
        //        let storeButton = MGSwipeButton.init(type: .custom)
        //        storeButton.backgroundColor = UIColor.mainRed()
        //        storeButton.setImage(UIImage(named: "icon_bag_more"), for: .normal)
        //        storeButton.setImage(UIImage(named: "icon_bag_more"), for: .highlighted)
        //        storeButton.setImage(UIImage(named: "icon_bag_more"), for: .selected)
        //        //storeButton.tintColor = .white
        //        storeButton.frame = CGRect.init(x: 0, y: 0, width: 69, height: 69)
        //        storeButton.callback = { [weak self] (buttnon) in
        //
        //                guard let strongSelf = self else {return true}
        //                guard let viewModel = strongSelf.viewModel else {return true}
        //
        //                strongSelf.chatCellDelegate?.chatCell(cell: strongSelf, action: .store, viewModel: viewModel)
        //
        //                return true
        //        }
        //self.rightButtons = [storeButton,favoriteButton]

        self.rightButtons = [muteButton]
        self.rightSwipeSettings.transition = .static

        self.leftButtons = [deleteButton]
        self.leftSwipeSettings.transition = .static

        // get unread count of message and set badgenumber
        let unreadMsgCount = viewModel.totalNumberOfUnreadMessages
        let numberText: String = (unreadMsgCount < 1000 ? "\(unreadMsgCount)" : "999+")
        let isHidden = (unreadMsgCount < 1)

        badgeNumberView.isHidden = isHidden
        badgeNumberLabel.text = numberText

        self.voipButton.isEnabled = !viewModel.isGroupChat
    }

    private func setupConstraints() {

        contentView.addViewsForAutolayout(views: [avatarImageView,statusBall,nameLabel,moodLabel,locationLabel,lineView,voipButton,/*favoriteButton,*/badgeNumberView])

        // setup constraint of imageProfile
        avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 17.0).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.0).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 45.0).isActive = true

        // setup constraint of message status
        statusBall.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 0).isActive = true
        statusBall.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 1).isActive = true
        statusBall.heightAnchor.constraint(equalToConstant: 16).isActive = true
        statusBall.widthAnchor.constraint(equalTo: statusBall.heightAnchor).isActive = true

        // setup constraint of name
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: moodLabel.topAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12).isActive = true

        // setup constraint of mood
        moodLabel.bottomAnchor.constraint(equalTo: locationLabel.topAnchor).isActive = true
        moodLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12).isActive = true
        moodLabel.trailingAnchor.constraint(equalTo: voipButton.leadingAnchor, constant: -19).isActive = true

        // setup constraint of mood
        locationLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12).isActive = true
        locationLabel.trailingAnchor.constraint(equalTo: voipButton.leadingAnchor, constant: -19).isActive = true

        // setup constraint of line
        lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        // setup constraint of favorite button
        /*
         favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
         favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
         favoriteButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
         favoriteButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
         */

        // setup constraint of VOIP button
        //voipButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -25.0).isActive = true
        voipButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -23).isActive = true
        voipButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        voipButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        voipButton.heightAnchor.constraint(equalToConstant: 25.0).isActive = true

        // setup constraint of badgeNumber
        badgeNumberView.addViewsForAutolayout(views: [badgeNumberLabel])

        badgeNumberView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor, constant: 0.0).isActive = true
        badgeNumberView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 4.0).isActive = true
        badgeNumberView.trailingAnchor.constraint(lessThanOrEqualTo: voipButton.leadingAnchor, constant: -19.0).isActive = true

        badgeNumberLabel.setContentCompressionResistancePriority(1000, for: .horizontal)
        badgeNumberLabel.topAnchor.constraint(equalTo: badgeNumberView.topAnchor, constant: 2.0).isActive = true
        badgeNumberLabel.bottomAnchor.constraint(equalTo: badgeNumberView.bottomAnchor, constant: -2.0).isActive = true
        badgeNumberLabel.leadingAnchor.constraint(equalTo: badgeNumberView.leadingAnchor, constant: 2.0).isActive = true
        badgeNumberLabel.trailingAnchor.constraint(equalTo: badgeNumberView.trailingAnchor, constant: -2.0).isActive = true
        badgeNumberLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 11.0).isActive = true
        badgeNumberLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 11.0).isActive = true

        // update frame
        contentView.layoutIfNeeded()

        badgeNumberView.layer.cornerRadius = badgeNumberView.frame.size.height / 2.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var comingSoonDelegate: UIView?

    func setComingSoonDelegate(delegate: UIView) {
        comingSoonDelegate = delegate
    }

    func callTapped(button: UIButton) {

        guard let viewModel = self.viewModel else {return}
        self.chatCellDelegate?.chatCell(cell: self, action: .call, viewModel:viewModel)
    }

    func favoriteTapped(button: UIButton) {
//        comingSoonDelegate?.makeToast(SystemMessage.ComingSoon.Favorite, duration: 1.0, position: .center)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    
}
