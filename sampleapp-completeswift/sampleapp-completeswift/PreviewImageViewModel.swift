//
//  PreviewImageViewModel.swift
//  Axiata
//
//  Created by appsynth on 2/8/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import Foundation

final class PreviewImageViewModel: NSObject {
    
    var imageUrl: URL
    private var savingImagesuccessBlock: (() -> ())?
    private var savingImagefailBlock: ((Error) -> ())?

    fileprivate var downloadImageSuccessBlock: (() -> ())?
    fileprivate var downloadImageFailBlock: ((String) -> ())?

    fileprivate let loadingFailErrorMessage = SystemMessage.Warning.DownloadOriginalImageFail


    init(imageUrl: URL) {

        self.imageUrl = imageUrl
    }


    func saveImage(image: UIImage?, successBlock: @escaping () -> (), failBlock: @escaping (Error) -> ()) {

        self.savingImagesuccessBlock   = successBlock
        self.savingImagefailBlock      = failBlock

        guard let image = image else {
            failBlock(NSError(domain: "IMAGE_NOT_AVAILABLE", code: 0 , userInfo: nil))
            return
        }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(PreviewImageViewModel.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error, let failBlock = savingImagefailBlock {
            failBlock(error)
        } else if let successBlock = savingImagesuccessBlock {
            successBlock()
        }
    }}
