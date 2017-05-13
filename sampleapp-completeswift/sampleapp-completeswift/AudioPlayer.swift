//
//  AudioPlayer.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 11/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioPlayerProtocol: class {
    func audioPlaying(maxDuratation:CGFloat,atSec:CGFloat,lastPlayTrack:String)
    func audioStop(maxDuratation:CGFloat,lastPlayTrack:String)
    //func audioPause(maxDuratation:CGFloat,atSec:CGFloat)
}

final class AudioPlayer {
    
    //sound file
    fileprivate var audioData:NSData?
    fileprivate var audioPlayer: AVAudioPlayer!
    fileprivate var audioLastPlay: String = ""
    
    private var timer = Timer()
    var secLeft:CGFloat = 0.0
    var maxDuration:CGFloat = 0.0
    weak var audiDelegate: AudioPlayerProtocol?
    
    func playAudio()
    {
        if audioData != nil && maxDuration > 0 {
            
            if secLeft == 0 {
                secLeft = CGFloat(audioPlayer.duration)
            }
            
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(AudioPlayer.updateCounter), userInfo: nil, repeats: true)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            }
            catch {
//                Logger.debug(message: "Cannot play in silent mode")
            }
            
            audioPlayer.stop()
            audioPlayer.play()
            
        }
    }
    
    func playAudioFrom(atTime:CGFloat)
    {
        if audioData != nil  && maxDuration > 0 {
            
            if secLeft <= 0 {
                secLeft = CGFloat(audioPlayer.duration)
            }
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(AudioPlayer.updateCounter), userInfo: nil, repeats: true)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            }
            catch {
//                Logger.debug(message: "Cannot play in silent mode")
            }
            
            audioPlayer.currentTime = TimeInterval.init(atTime)
            audioPlayer.play()
        } else {
            stopAudio()
        }
    }
    
    func pauseAudio() {
        if audioData != nil,secLeft > 0 {
            timer.invalidate()
            audioPlayer.pause()
        }
        else {
            
            timer.invalidate()
            audioPlayer.stop()
            
            if audiDelegate != nil {
                audiDelegate?.audioStop(maxDuratation:maxDuration,lastPlayTrack:audioLastPlay)
            }
        }
    }
    
    func stopAudio()
    {
        if audioData != nil {
            
            if secLeft > 0 {
                pauseAudio()
            } else {
                secLeft = 0
                timer.invalidate()
                audioPlayer.stop()
                if audiDelegate != nil {
                    audiDelegate?.audioStop(maxDuratation:maxDuration,lastPlayTrack:audioLastPlay)
                }
            }
        }
    }
    
    func getCurrentAudioTrack() -> String
    {
        return audioLastPlay
    }
    
    @objc fileprivate func updateCounter() {
        
        if secLeft <= 0
        {
            secLeft = 0
            timer.invalidate()
            audioPlayer.stop()
            
            if audiDelegate != nil {
                audiDelegate?.audioStop(maxDuratation: maxDuration,lastPlayTrack:audioLastPlay)
            }
        }
        else
        {
            secLeft -= 1
            if audiDelegate != nil {
                let timeLeft = audioPlayer.duration-audioPlayer.currentTime
                audiDelegate?.audioPlaying(maxDuratation: maxDuration, atSec: CGFloat(timeLeft),lastPlayTrack:audioLastPlay)
            }
        }
    }
    
    func setAudioFile(data:NSData,delegate:AudioPlayerProtocol,playFrom:CGFloat,lastPlayTrack:String)
    {
        //setup player
        do {
            audioData = data
            audioPlayer = try AVAudioPlayer(data: data as Data, fileTypeHint: AVFileTypeWAVE)
            audioPlayer?.prepareToPlay()
            audioPlayer.volume = 1.0
            audiDelegate = delegate
            audioLastPlay = lastPlayTrack
            
            secLeft = playFrom
            maxDuration = CGFloat(audioPlayer.duration)
            
            if maxDuration == playFrom || playFrom <= 0 {
                playAudio()
            } else {
                let startFrom = maxDuration - playFrom
                if playFrom <= 0 {
                    playAudio()
                }
                else  {
                    playAudioFrom(atTime: startFrom)
                }
            }
            
        } catch let error as NSError {
//            Logger.error(message: error)
        }
    }
    
}

