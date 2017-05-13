//
//  DownloadManager.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 12/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Alamofire
import Applozic

class DownloadManager {
    static let shared = DownloadManager()
    
    func downloadAndSaveAudio(message: ALMessage, completion: @escaping (_ path: String?) ->()) {
        let urlStr = String(format: "%@/rest/ws/aws/file/%@",ALUserDefaultsHandler.getFILEURL(),message.fileMeta.blobKey)
        let componentsArray = message.fileMeta.name.components(separatedBy: ".")
        let fileExtension = componentsArray.last
        let filePath = String(format: "%@_local.%@", message.key, fileExtension!)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fullPath = documentsURL.appendingPathComponent(filePath)
            
            return (fullPath,[])
        }
        
        Alamofire.download(urlStr, to: destination).response { response in
            print(response)
            
            if response.error == nil, let path = response.destinationURL?.path {
                completion(filePath)
            } else {
                NSLog("error while downloading: \(response.error)")
                completion(nil)
            }
        }
    }
    
}
