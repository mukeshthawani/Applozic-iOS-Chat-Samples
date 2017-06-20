//
//  API.swift
//  Axiata
//
//  Created by Nitigron Ruengmontre on 12/7/2559 BE.
//  Copyright © 2559 Appsynth. All rights reserved.
//

import Foundation
import ObjectMapper
import AlamofireObjectMapper
import Alamofire


final class API: NSObject {
    static func requestForItems<T: Mappable>(request: APIRequest,
                                completionHandler: @escaping (_ items: [T]?, _ isCache: Bool, _ error: Error?) -> Void) {

//        FirebaseTokenProvider.shared.getToken { (token, error) in

//            guard let token = token else {
//                completionHandler(nil, false, error)
//                return
//            }

            let method      = request.type.methodOfAlamofire()
            let paramsType  = getEncoding(paramType: request.paramsType)
            let params      = request.params
            let headers: HTTPHeaders = [:]

//            Logger.debug(message: headers)
//            Logger.debug(message: params ?? "")

            Alamofire.request(request.url, method: method, parameters: params, encoding: paramsType, headers: headers)
                .validate(statusCode: 200 ..< 300)
                .responseArray(keyPath: request.responseKeyPath) { (response: DataResponse<[T]>) in

//                    printResponse(response: response)
                    completionHandler(response.result.value,
                                      false,
                                      response.result.error)
            }


//        }

    }

    private static func getEncoding(paramType: APIParameterType) -> ParameterEncoding {
        var encoding: ParameterEncoding = URLEncoding.default
        switch paramType {
        case .url:
            encoding = URLEncoding.default
        case .urlEncodedInURL:
            encoding = URLEncoding.default
        case .json:
            encoding = JSONEncoding.default
        }
        return encoding

    }
}
