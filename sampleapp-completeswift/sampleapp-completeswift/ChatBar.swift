//
//  ChatBar.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 05/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import AwesomeCache


final class ChatBar: UIView {
    
    enum ButtonMode {
        case send
        case media
    }
    
    enum ActionType {
        case sendText(UIButton,String)
        case chatBarTextBeginEdit()
        case chatBarTextChange(UIButton)
        case sendPhoto(UIButton,UIImage)
        case sendVoice(NSData)
        case startVoiceRecord()
        case noVoiceRecordPermission()
        case mic(UIButton)
        case more(UIButton)
    }
    
    var action: ((ActionType) -> ())?
    fileprivate var cache: Cache<NSString>?
    
    let soundRec: SoundRecorderBtn = {
        let bt = SoundRecorderBtn.init(frame: CGRect.init())
        bt.layer.masksToBounds = true
        return bt
    }()
    
    let textView: ALChatBarTextView = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4.0
        let tv = ALChatBarTextView()
        tv.setBackgroundColor(color: .none)
        tv.clipsToBounds = true
        tv.scrollsToTop = false
        tv.autocapitalizationType = .sentences
        tv.accessibilityIdentifier = "chatTextView"
        tv.typingAttributes = [NSParagraphStyleAttributeName: style, NSFontAttributeName: UIFont.font(.normal(size: 14.0))]
        return tv
    }()
    
    fileprivate let frameView: UIImageView = {
        
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleToFill
        view.image = UIImage.init(named: "text_frame")
        view.isUserInteractionEnabled = false
        return view
    }()
    
    fileprivate let grayView: UIView = {
        
        let view = UIView()
        view.setBackgroundColor(color: .grayEF)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    fileprivate let placeHolder: UITextView = {
        
        let view = UITextView()
        view.setFont(font: .normal(size: 14))
        view.setTextColor(color: .gray9B)
        view.text = SystemMessage.Information.ChatHere
        view.isUserInteractionEnabled = false
        view.isScrollEnabled = false
        view.scrollsToTop = false
        view.setBackgroundColor(color: .none)
        return view
    }()
    
    fileprivate let micButton: UIButton = {
        
        let bt = UIButton(type: .custom)
        bt.setImage(UIImage(named:"icon_mic"), for: .normal)
        bt.setImage(UIImage(named:"icon_mic_active"), for: .selected)
        return bt
    }()
    
    fileprivate let photoButton: UIButton = {
        
        let bt = UIButton(type: .custom)
        bt.setImage(UIImage(named: "icon_camera"), for: .normal)
        return bt
    }()
    
    fileprivate let plusButton: UIButton = {
        
        let bt = UIButton(type: .custom)
        bt.setImage(UIImage(named: "icon_more_menu"), for: .normal)
        return bt
    }()
    
    fileprivate let sendButton: UIButton = {
        
        let bt = UIButton(type: .custom)
        bt.setImage(UIImage(named: "icon_send"), for: .normal)
        bt.accessibilityIdentifier = "sendButton"
        
        return bt
    }()
    
    private var lineView: UIView = {
        let view = UIView()
        let layer = view.layer
        view.backgroundColor = UIColor(colorLiteralRed: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        return view
    }()
    
    
    func tapped(button: UIButton) {
        
        switch button {
        case sendButton:
            
            let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if text.lengthOfBytes(using: .utf8) > 0 {
                action?(.sendText(button,text))
                
                if let identifier = chatIdentifier {
                    cache?.setObject(NSString(string: ""), forKey: identifier)
                }
            }
            
            break
            
        case plusButton:
            action?(.more(button))
            break
            
        case photoButton:
            
            let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.camera)
            if let vc = storyboard.instantiateViewController(withIdentifier: "CustomCameraNavigationController") as? ALBaseNavigationViewController {
                guard let firstVC = vc.viewControllers.first else {return}
                let cameraView = firstVC as! CustomCameraViewController
                cameraView.setCustomCamDelegate(camMode: .NoCropOption, camDelegate: self)
                UIViewController.topViewController()?.present(vc, animated: false, completion: nil)
            }
            break
            
        case micButton:
//            if soundRec.isHidden {
//                micButton.isSelected = true
//                soundRec.isHidden = false
//                
//                if placeHolder.isFirstResponder {
//                    placeHolder.resignFirstResponder()
//                } else if textView.isFirstResponder {
//                    textView.resignFirstResponder()
//                }
//                
//                soundRec.setSoundRecDelegate(recorderDelegate: self)
//            } else {
//                micButton.isSelected = false
//                soundRec.isHidden = true
//            }
//            
            break
        default: break
            
        }
    }
    
    fileprivate func toggleKeyboardType(textView: UITextView) {
        
        textView.keyboardType = .asciiCapable
        textView.reloadInputViews()
        textView.keyboardType = .default;
        textView.reloadInputViews()
    }
    
    private weak var comingSoonDelegate: UIView?
    
    var chatIdentifier: String?
    
    func setComingSoonDelegate(delegate: UIView) {
        comingSoonDelegate = delegate
    }
    
    func clear() {
        
        textView.text = ""
        clearTextInTextView()
        toggleKeyboardType(textView: textView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        do {
            cache = try Cache<NSString>(name: "ChatBat-TextView")
        } catch {
            NSLog("ChatBat-TextView Failed")
        }
        
        textView.delegate = self
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        
        micButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        photoButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        
        setupConstraints()
    }
    
    deinit {
        
        if let identifier = chatIdentifier, let text = textView.text {
            if !text.isEmpty {
                let string = NSString(string: text)
                cache?.setObject(string, forKey: identifier)
            } else{
                cache?.setObject("", forKey: identifier)
            }
        }
        
        micButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        plusButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        photoButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        sendButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
    }
    
    private var isNeedInitText = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isNeedInitText {
            
            guard let identifier = chatIdentifier else {
                return
            }
            
            if let cache = cache, let text = cache.object(forKey: identifier) {
                let initText = text as String
                
                if !initText.isEmpty {
                    textView.text = initText
                    _ = textView(textView, shouldChangeTextIn: NSRange.init(location: 0, length: initText.characters.count), replacementText: initText)
                    textViewDidChange(textView)
                }
            }
            
            isNeedInitText = false
        }
        
    }
    
    fileprivate var textViewHeighConstrain: NSLayoutConstraint?
    fileprivate let textViewHeigh: CGFloat = 30.0
    fileprivate let textViewHeighMax: CGFloat = 102.2 + 8.0
    
    fileprivate var textViewTrailingWithSend: NSLayoutConstraint?
    fileprivate var textViewTrailingWithMic: NSLayoutConstraint?
    
    private func setupConstraints() {
        
        addViewsForAutolayout(views: [micButton, plusButton, photoButton, sendButton, grayView, textView, lineView, frameView, placeHolder,soundRec])
        
        lineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        lineView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        photoButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        photoButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        photoButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        photoButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        micButton.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor).isActive = true
        micButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        micButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        micButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        
        plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
        plusButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        
        sendButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7).isActive = true
        textView.leadingAnchor.constraint(equalTo: photoButton.trailingAnchor, constant: 3).isActive = true
        
        textViewTrailingWithMic = textView.trailingAnchor.constraint(equalTo: micButton.leadingAnchor, constant: -8)
        textViewTrailingWithSend = textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor)
        
        textViewHeighConstrain = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: textViewHeigh)
        textViewHeighConstrain?.isActive = true
        
        placeHolder.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
        placeHolder.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        placeHolder.leftAnchor.constraint(equalTo: textView.leftAnchor, constant: 0).isActive = true
        placeHolder.rightAnchor.constraint(equalTo: textView.rightAnchor, constant: 0).isActive = true
        
        soundRec.isHidden = true
        soundRec.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
        soundRec.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        soundRec.leadingAnchor.constraint(equalTo: photoButton.trailingAnchor, constant: -4).isActive = true
        soundRec.rightAnchor.constraint(equalTo: textView.rightAnchor, constant: 0).isActive = true
        
        frameView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        frameView.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 4).isActive = true
        frameView.leadingAnchor.constraint(equalTo: photoButton.trailingAnchor, constant: -4).isActive = true
        frameView.rightAnchor.constraint(equalTo: textView.rightAnchor, constant: 2).isActive = true
        
        grayView.topAnchor.constraint(equalTo: frameView.topAnchor, constant: 0).isActive = true
        grayView.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 0).isActive = true
        grayView.leftAnchor.constraint(equalTo: frameView.leftAnchor, constant: 0).isActive = true
        grayView.rightAnchor.constraint(equalTo: frameView.rightAnchor, constant: 0).isActive = true
        
        bringSubview(toFront: frameView)
        
        changeButtonStateTo(mode: textView.text.isEmpty ? ButtonMode.media : ButtonMode.send)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func changeButtonStateTo(mode: ButtonMode){
        
        if mode == .media {
            
            self.textViewTrailingWithSend?.isActive = false
            self.textViewTrailingWithMic?.isActive = true
            
            self.micButton.isUserInteractionEnabled = true
            self.plusButton.isUserInteractionEnabled = true
            self.sendButton.isUserInteractionEnabled = false
            
            self.layoutIfNeeded()
            
            self.micButton.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.plusButton.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.sendButton.transform = CGAffineTransform.init(scaleX: 0, y: 0)
            
            self.micButton.alpha = 1
            self.plusButton.alpha = 1
            self.sendButton.alpha = 0
            
            
        } else {
            
            self.textViewTrailingWithMic?.isActive = false
            self.textViewTrailingWithSend?.isActive = true
            
            self.micButton.isUserInteractionEnabled = false
            self.plusButton.isUserInteractionEnabled = false
            self.sendButton.isUserInteractionEnabled = true
            
            self.layoutIfNeeded()
            
            self.micButton.transform = CGAffineTransform.init(scaleX: 0, y: 0)
            self.plusButton.transform = CGAffineTransform.init(scaleX: 0, y: 0)
            self.sendButton.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            
            self.micButton.alpha = 0
            self.plusButton.alpha = 0
            self.sendButton.alpha = 1
            
        }
    }
    
}

extension ChatBar: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool {
        guard var text = textView.text as NSString? else {
            return true
        }
        
        text = text.replacingCharacters(in: range, with: string) as NSString
        
        changeButtonStateTo(mode: text == "" ? ButtonMode.media : ButtonMode.send)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4.0
        let font = textView.font ?? UIFont.font(.normal(size: 14.0))
        let attributes = [NSParagraphStyleAttributeName: style, NSFontAttributeName: font]
        let tv = UITextView(frame: textView.frame)
        tv.attributedText = NSAttributedString(string: text as String, attributes:attributes)
        
        let fixedWidth = textView.frame.size.width
        let size = tv.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if let textViewHeighConstrain = self.textViewHeighConstrain, size.height != textViewHeighConstrain.constant  {
            
            if size.height < self.textViewHeighMax {
                textViewHeighConstrain.constant = size.height > self.textViewHeigh ? size.height : self.textViewHeigh
            } else if textViewHeighConstrain.constant != self.textViewHeighMax {
                textViewHeighConstrain.constant = self.textViewHeighMax
            }
            
            textView.layoutIfNeeded()
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.placeHolder.isHidden = !textView.text.isEmpty
        self.placeHolder.alpha = textView.text.isEmpty ? 1.0 : 0.0
        
        if let selectedTextRange = textView.selectedTextRange {
            let line = textView.caretRect(for: selectedTextRange.start)
            let overflow = line.origin.y + line.size.height  - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top )
            
            if overflow > 0 {
                var offset = textView.contentOffset;
                offset.y += overflow + 8.2 // leave 8.2 pixels margin
                
                textView.setContentOffset(offset, animated: false)
            }
        }
        action?(.chatBarTextChange(photoButton))
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        action?(.chatBarTextBeginEdit())
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            if self.placeHolder.isHidden {
                self.placeHolder.isHidden = false
                self.placeHolder.alpha = 1.0
                
                DispatchQueue.main.async { [weak self] in
                    guard let weakSelf = self else { return }
                    
                    weakSelf.textViewHeighConstrain?.constant = weakSelf.textViewHeigh
                    UIView.animate(withDuration: 0.15) {
                        weakSelf.layoutIfNeeded()
                    }
                }
            }
        }
        
        //clear inputview of textview
        textView.inputView = nil
        textView.reloadInputViews()
    }
    
    fileprivate func clearTextInTextView() {
        if textView.text.isEmpty {
            
            if self.placeHolder.isHidden {
                self.placeHolder.isHidden = false
                self.placeHolder.alpha = 1.0
                
                textViewHeighConstrain?.constant = textViewHeigh
                layoutIfNeeded()
            }
        }
        textView.inputView = nil
        textView.reloadInputViews()
        changeButtonStateTo(mode: textView.text.isEmpty ? ButtonMode.media : ButtonMode.send)
    }
}

extension ChatBar: CustomCameraProtocol {
    
    func customCameraDidTakePicture(cropedImage: UIImage) {
        action?(.sendPhoto(photoButton, cropedImage))
    }
}

//extension ChatBar: SoundRecorderProtocol {
//    
//    func stopRecording() {
//        soundRec.cancelAudioRecord()
//    }
//    
//    func startRecordingAudio() {
//        action?(.startVoiceRecord())
//    }
//    
//    func finishRecordingAudio(soundData: NSData) {
////        Logger.debug(message: "receive recording..")
//        textView.resignFirstResponder()
//        action?(.sendVoice(soundData))
//    }
//    
//    func cancelRecordingAudio() {
//        soundRec.isHidden = true
//        micButton.isSelected = false
//        textView.becomeFirstResponder()
//    }
//    
//    func permissionNotGrant() {
//        action?(.noVoiceRecordPermission())
//    }
//}
