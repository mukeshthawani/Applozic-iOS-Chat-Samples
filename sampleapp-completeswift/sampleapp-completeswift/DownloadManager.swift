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
    
    func uploadImage(message: ALMessage, databaseObj: DB_FileMetaInfo, uploadURL: String, completion:@escaping (_ response: Any?)->()) {
        let docDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timeStamp = message.imageFilePath
        let filePath = docDirPath.appendingPathComponent(timeStamp!)
        
        guard var request = ALRequestHandler.createPOSTRequest(withUrlString: uploadURL, paramString: nil) as URLRequest? else { return }
        if FileManager.default.fileExists(atPath: filePath.path) {
            
            let boundary = "------ApplogicBoundary4QuqLuM1cE5lMwCy"
            let contentType = String(format: "multipart/form-data; boundary=%@", boundary)
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            var body = Data()
            
            let parameters = [String: String]()
            
            let fileParamConstant = "files[]"
            let imageData = NSData(contentsOfFile: filePath.path)
            
            if let data = imageData as Data? {
                print("data present")
                body.append(String(format: "--%@\r\n", boundary).data(using: .utf8)!)
                body.append(String(format: "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileParamConstant,message.fileMeta.name).data(using: .utf8)!)
                body.append(String(format: "Content-Type:%@\r\n\r\n", message.fileMeta.contentType).data(using: .utf8)!)
                body.append(data)
                body.append(String(format: "\r\n").data(using: .utf8)!)
            }
            
            body.append(String(format: "--%@--\r\n", boundary).data(using: .utf8)!)
            request.httpBody = body
            request.url = URL(string: uploadURL)
            
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                do {
                    let responseDictionary = try JSONSerialization.jsonObject(with: data!)
                    print("success == \(responseDictionary)")
                    completion(responseDictionary)
                } catch {
                    print(error)
                    
                    let responseString = String(data: data!, encoding: .utf8)
                    print("responseString = \(responseString)")
                    completion(nil)
                }
            }
            task.resume()
        }
    }
    
}
