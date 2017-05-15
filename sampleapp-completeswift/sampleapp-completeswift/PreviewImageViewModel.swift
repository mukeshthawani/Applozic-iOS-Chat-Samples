//
//  PreviewImageViewModel.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 13/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

final class PreviewImageViewModel: NSObject {
    
//    let messagePart: LYRMessagePart
    var image: UIImage? = nil
    
    private var savingImagesuccessBlock: (() -> ())?
    private var savingImagefailBlock: ((Error) -> ())?
    
    fileprivate var downloadImageSuccessBlock: (() -> ())?
    fileprivate var downloadImageFailBlock: ((String) -> ())?
    
    fileprivate let loadingFailErrorMessage = SystemMessage.Warning.DownloadOriginalImageFail
    
    var privateKVOContext: Int = 0
    
//    init(messagePart: LYRMessagePart) {
//        self.messagePart = messagePart
//        super.init()
//        self.messagePart.addObserver(self, forKeyPath: "transferStatus", options: .new, context: &privateKVOContext)
//    }
    
    
    
//    func saveImage(successBlock: @escaping () -> (), failBlock: @escaping (Error) -> ()) {
//        
//        self.savingImagesuccessBlock   = successBlock
//        self.savingImagefailBlock      = failBlock
//        
//        guard let image = image else {
//            failBlock(NSError(domain: "IMAGE_NOT_AVAILABLE", code: 0 , userInfo: nil))
//            return
//        }
//        
//        UIImageWriteToSavedPhotosAlbum(image, self, #selector(PreviewImageViewModel.image(_:didFinishSavingWithError:contextInfo:)), nil)
//    }
//    
//    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error, let failBlock = savingImagefailBlock {
//            failBlock(error)
//        } else if let successBlock = savingImagesuccessBlock {
//            successBlock()
//        }
//    }
}

//extension LYRContentTransferStatus {
//    
//    func transferStatusString() -> String {
//        switch self {
//        case .awaitingUpload:
//            return "Awaiting Upload (Available locally. is yet to be uploaded)"
//        case .uploading:
//            return "Uploading (Available locally)"
//        case .readyForDownload:
//            return "Ready for download (Not available locally)"
//        case .downloading:
//            return "Downloading (Not yet available locally)"
//        case .complete:
//            return "Complete (Available locally)"
//        }
//    }
//}
//
//// MARK: - Image downloading
//extension PreviewImageViewModel {
//    
//    func prepareActualImage(successBlock: @escaping () -> (), failBlock: @escaping (_ errorMessage: String) -> ()) {
//        
//        if let fileURL = self.messagePart.fileURL,
//            let image = UIImage(contentsOfFile: fileURL.path) {
//            
//            let log = "PREVIEW: Show local image file for id \(messagePart.identifier)"
//            Logger.verbose(message: log, tag: .showOriginalPhotoFromLocal)
//            
//            self.image = image
//            successBlock()
//            return
//        }
//        
//        let log = "PREVIEW: Transfer status \(messagePart.transferStatus.transferStatusString()) for id \(messagePart.identifier)"
//        Logger.verbose(message: log, tag: .downloadOriginalPhotoInfo)
//        
//        switch messagePart.transferStatus {
//            
//        case .readyForDownload:
//            do {
//                Logger.debug(message: "prepareActualImage >> message part \(messagePart)")
//                downloadImageSuccessBlock   = successBlock
//                downloadImageFailBlock      = failBlock
//                
//                let log = "PREVIEW: Start download original photo id \(messagePart.identifier)"
//                Logger.verbose(message: log , tag: .statusReadyForDownloadStartLoadingOriginalPhoto)
//                
//                try self.messagePart.downloadContent()
//                
//            } catch {
//                let log = "PREVIEW: Fail to download photo content even status is ready \(messagePart.identifier)"
//                Logger.verbose(message: log , tag: .statusReadyDownloadOriginalPhotoFailAtFirst)
//                
//                failBlock(loadingFailErrorMessage)
//            }
//        case .complete:
//            guard let imageData = messagePart.data else {
//                let log = "PREVIEW: No original photo even the status complete \(messagePart.identifier)"
//                Logger.verbose(message: log , tag: .statusCompletedNoOriginalPhotoData)
//                
//                failBlock(loadingFailErrorMessage)
//                return
//            }
//            
//            Logger.debug(message: "prepareActualImage >> Image Data Available \(imageData.count)")
//            if let image =  UIImage(data: imageData) {
//                self.image = image
//                successBlock()
//            } else {
//                failBlock(loadingFailErrorMessage)
//            }
//            
//        case .downloading:
//            downloadImageSuccessBlock   = successBlock
//            downloadImageFailBlock      = failBlock
//            
//            /* For debug later in case a problems occurs
//             Logger.debug(message: "prepareActualImage downloadImageSuccessBlock \(downloadImageSuccessBlock)")
//             Logger.debug(message: "prepareActualImage downloadImageFailBlock \(downloadImageFailBlock)")
//             Logger.debug(message: "prepareActualImage self.messagePart.progress \(self.messagePart.progress)")
//             Logger.debug(message: "prepareActualImage messagePart.data \(messagePart.data)")
//             */
//            
//            let log = "PREVIEW: Transfer status is Downloading \(messagePart.identifier)"
//            Logger.verbose(message: log , tag: .statusDownloadingDownloadingPhoto)
//            
//            // Re-download
//            if messagePart.transferStatus == .complete && messagePart.data == nil {
//                do {
//                    let log = "PREVIEW: Transfer status is Downloading with fraction complete, but no photo data \(messagePart.identifier)"
//                    Logger.verbose(message: log , tag: .statusDownloadingWithCompletedFractionButNoPhotoData)
//                    
//                    try self.messagePart.purgeContent()
//                    try self.messagePart.downloadContent()
//                    self.messagePart.addObserver(self, forKeyPath: "transferStatus", options: .new, context: nil)
//                    
//                } catch {
//                    Logger.debug(message: "prepareActualImage >> Fail to download image content: message part \(messagePart)")
//                    failBlock(loadingFailErrorMessage)
//                }
//            }
//        case .uploading:
//            failBlock(SystemMessage.Warning.ImageBeingUploaded)
//        default:()
//        failBlock("")
//        }
//    }
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        
//        if context == &privateKVOContext {
//            
//            DispatchQueue.main.async { [weak self] () in
//                
//                guard let strongSelf = self else {return}
//                
//                if keyPath == "transferStatus" {
//                    
//                    if let messagePart = object as? LYRMessagePart, messagePart.transferStatus == .complete {
//                        
//                        guard let imageData = messagePart.data else {
//                            guard let completion = strongSelf.downloadImageFailBlock else { return }
//                            let log = "PREVIEW: Progress: Fraction Completed but no data \(messagePart.identifier)"
//                            Logger.verbose(message: log , tag: .progressWithCompletedFractionButNoPhotoData)
//                            
//                            completion(strongSelf.loadingFailErrorMessage)
//                            return
//                        }
//                        
//                        Logger.debug(message: "progressDidChange >> fractionCompleted \(imageData.count)")
//                        
//                        if let image =  UIImage(data: imageData) {
//                            strongSelf.image = image
//                            let log = "PREVIEW: Progress: Download complete \(messagePart.identifier)"
//                            Logger.verbose(message: log , tag: .progressDownloadOriginalPhotoSuccessfully)
//                            strongSelf.downloadImageSuccessBlock?()
//                        } else {
//                            strongSelf.downloadImageFailBlock?(strongSelf.loadingFailErrorMessage)
//                        }
//                    }
//                    
//                }
//            }
//            
//            
//        } else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
//        
//    }
//}


//// MARK: - LYRProgressDelegate
//extension PreviewImageViewModel: LYRProgressDelegate {
//    
//    func progressDidChange(_ progress: LYRProgress) {
//        Logger.debug(message: "PreviewImageViewModel progressDidChange >> progress \(messagePart.transferStatus.rawValue) \(progress.fractionCompleted): \(progress.completedUnitCount)/\(progress.totalUnitCount)")
//        
//        if progress.fractionCompleted == 1.0 {
//            guard let imageData = messagePart.data else {
//                guard let completion = downloadImageFailBlock else { return }
//                let log = "PREVIEW: Progress: Fraction Completed but no data \(messagePart.identifier)"
//                Logger.verbose(message: log , tag: .progressWithCompletedFractionButNoPhotoData)
//                
//                completion(loadingFailErrorMessage)
//                return
//            }
//            Logger.debug(message: "progressDidChange >> fractionCompleted \(imageData.count)")
//            
//            if let image =  UIImage(data: imageData) {
//                self.image = image
//                let log = "PREVIEW: Progress: Download complete \(messagePart.identifier)"
//                Logger.verbose(message: log , tag: .progressDownloadOriginalPhotoSuccessfully)
//                downloadImageSuccessBlock?()
//            } else {
//                downloadImageFailBlock?(loadingFailErrorMessage)
//            }
//        }
//        
//    }
//}

