////
////  VoiceCell.swift
////  sampleapp-completeswift
////
////  Created by Mukesh Thawani on 07/05/17.
////  Copyright © 2017 Applozic. All rights reserved.
////
//
//import Foundation
//
//import UIKit
//import Foundation
//import Kingfisher
//import AVFoundation
//import MBProgressHUD
//
//protocol VoiceCellProtocol: class {
//    func playAudioPress(identifier: String)
//}
//
//enum VoiceCellState {
//    case playing
//    case stop
//    case pause
//}
//
//class VoiceCell:ChatBaseCell<MessageViewModel> {
//    
//    var soundPlayerView: UIView = {
//        let mv = UIView()
//        mv.backgroundColor = UIColor.background(.grayF2)
//        mv.contentMode = .scaleAspectFill
//        mv.clipsToBounds = true
//        mv.layer.cornerRadius = 12
//        return mv
//    }()
//    
//    fileprivate let frameView: UIImageView = {
//        let view = UIImageView()
//        view.backgroundColor = .clear
//        view.contentMode = .scaleToFill
//        view.image = UIImage.init(named: "text_frame")
//        view.isUserInteractionEnabled = false
//        return view
//    }()
//    
//    var playTimeLabel: UILabel = {
//        let lb = UILabel()
//        return lb
//    }()
//    
//    var progressBar: UIProgressView = {
//        let progress = UIProgressView()
//        progress.trackTintColor = UIColor.clear
//        progress.tintColor = UIColor.background(.main).withAlphaComponent(0.32)
//        return progress
//    }()
//    
//    var timeLabel: UILabel = {
//        let lb = UILabel()
//        return lb
//    }()
//    
//    var actionButton: UIButton = {
//        let button = UIButton(type: .custom)
//        button.backgroundColor = .clear
//        return button
//    }()
//    
//    var clearButton: UIButton = {
//        let button = UIButton(type: .custom)
//        button.backgroundColor = .clear
//        return button
//    }()
//    
//    var bubbleView: UIView = {
//        let bv = UIView()
//        bv.backgroundColor = .gray
//        bv.layer.cornerRadius = 12
//        bv.isUserInteractionEnabled = false
//        return bv
//    }()
//    
//    class func topPadding() -> CGFloat {
//        return 12
//    }
//    
//    class func bottomPadding() -> CGFloat {
//        return 12
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
//    
//    override class func rowHeigh(viewModel: MessageViewModel,width: CGFloat) -> CGFloat {
//        
//        let heigh: CGFloat
//        heigh = 37
//        return topPadding()+heigh+bottomPadding()
//    }
//    
//    
//    func getTimeString(secLeft:CGFloat) -> String {
//        
//        let min = (Int(secLeft) / 60) % 60
//        let sec = (Int(secLeft) % 60)
//        let minStr = String(min)
//        var secStr = String(sec)
//        if sec < 10 {secStr = "0\(secStr)"}
//        
//        return "\(minStr):\(secStr)"
//    }
//    
//    
//    override func update(viewModel: MessageViewModel) {
//        super.update(viewModel: viewModel)
//        
//        //pause case
//        if viewModel.voiceCurrentState == .pause && viewModel.voiceCurrentDuration > 0{
//            actionButton.isSelected = false
//            playTimeLabel.text = getTimeString(secLeft:viewModel.voiceCurrentDuration)
//        } else if viewModel.voiceCurrentState == .playing {
//            actionButton.isSelected = true
//            playTimeLabel.text = getTimeString(secLeft:viewModel.voiceCurrentDuration)
//        }
//        else if viewModel.voiceCurrentState == .stop {
//            actionButton.isSelected = false
//            playTimeLabel.text = getTimeString(secLeft:viewModel.voiceTotalDuration)
//        } else {
//            actionButton.isSelected = false
//            playTimeLabel.text = getTimeString(secLeft:viewModel.voiceTotalDuration)
//        }
//        
//        let timeLeft = Int(viewModel.voiceTotalDuration)-Int(viewModel.voiceCurrentDuration)
//        let totalTime = Int(viewModel.voiceTotalDuration)
//        let percent = viewModel.voiceTotalDuration == 0 ? 0 : Float(timeLeft)/Float(totalTime)
//        
//        if viewModel.voiceCurrentState == .stop || viewModel.voiceCurrentDuration == 0 {
//            progressBar.setProgress(0, animated: false)
//        }
//        else {
//            progressBar.setProgress(Float(percent), animated: false)
//        }
//        timeLabel.text   = viewModel.time
//    }
//    
//    weak var voiceDelegate: VoiceCellProtocol?
//    
//    func setCellDelegate(delegate:VoiceCellProtocol) {
//        voiceDelegate = delegate
//    }
//    
//    func actionTapped() {
//        
//        guard let _ = viewModel?.voiceMessagePart else { return }
//        guard let identifier = viewModel?.identifierString else {return}
//        voiceDelegate?.playAudioPress(identifier: identifier)
//    }
//    
//    override func setupStyle() {
//        super.setupStyle()
//        timeLabel.setStyle(style: MessageStyle.time)
//        playTimeLabel.setStyle(style: MessageStyle.playTime)
//    }
//    
//    override func setupViews() {
//        super.setupViews()
//        
//        actionButton.setImage(UIImage(named: "icon_play"), for: .normal)
//        actionButton.setImage(UIImage(named: "icon_pause"), for: .selected)
//        
//        clearButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
//        
//        contentView.addViewsForAutolayout(views: [soundPlayerView,bubbleView,progressBar,actionButton,playTimeLabel,frameView,timeLabel,clearButton])
//        contentView.bringSubview(toFront: soundPlayerView)
//        contentView.bringSubview(toFront: progressBar)
//        contentView.bringSubview(toFront: actionButton)
//        contentView.bringSubview(toFront: playTimeLabel)
//        contentView.bringSubview(toFront: clearButton)
//        contentView.bringSubview(toFront: frameView)
//        
//        bubbleView.topAnchor.constraint(equalTo: soundPlayerView.topAnchor).isActive = true
//        bubbleView.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor).isActive = true
//        bubbleView.leftAnchor.constraint(equalTo: soundPlayerView.leftAnchor).isActive = true
//        bubbleView.rightAnchor.constraint(equalTo: soundPlayerView.rightAnchor).isActive = true
//        
//        progressBar.topAnchor.constraint(equalTo: soundPlayerView.topAnchor).isActive = true
//        progressBar.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor).isActive = true
//        progressBar.leftAnchor.constraint(equalTo: soundPlayerView.leftAnchor).isActive = true
//        progressBar.rightAnchor.constraint(equalTo: soundPlayerView.rightAnchor, constant: -2).isActive = true
//        
//        frameView.topAnchor.constraint(equalTo: soundPlayerView.topAnchor, constant: 0).isActive = true
//        frameView.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor, constant: 0).isActive = true
//        frameView.leftAnchor.constraint(equalTo: soundPlayerView.leftAnchor, constant: 0).isActive = true
//        frameView.rightAnchor.constraint(equalTo: soundPlayerView.rightAnchor, constant: 0).isActive = true
//        
//        clearButton.topAnchor.constraint(equalTo: soundPlayerView.topAnchor).isActive = true
//        clearButton.bottomAnchor.constraint(equalTo: soundPlayerView.bottomAnchor).isActive = true
//        clearButton.leftAnchor.constraint(equalTo: soundPlayerView.leftAnchor).isActive = true
//        clearButton.rightAnchor.constraint(equalTo: soundPlayerView.rightAnchor).isActive = true
//        
//        actionButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
//        actionButton.leftAnchor.constraint(equalTo: soundPlayerView.leftAnchor,constant:15).isActive = true
//        actionButton.widthAnchor.constraint(equalToConstant: 11).isActive = true
//        actionButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
//        
//        playTimeLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
//        playTimeLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
//        playTimeLabel.leftAnchor.constraint(greaterThanOrEqualTo: actionButton.leftAnchor,constant:25).isActive = true
//        playTimeLabel.rightAnchor.constraint(greaterThanOrEqualTo: actionButton.rightAnchor,constant:25).isActive = true
//        
//    }
//    
//    deinit {
//        clearButton.removeTarget(self, action: #selector(actionTapped), for: .touchUpInside)
//        actionButton.removeTarget(self, action: #selector(actionTapped), for: .touchUpInside)
//    }
//    
//}
