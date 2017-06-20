//
//  APIRequest.swift
//  Axiata
//
//  Created by appsynth on 12/20/16.
//  Copyright © 2016 Appsynth. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

enum APIRequestType {
    case get
    case post
    case delete
    case put
    
    func methodOfAlamofire() -> Alamofire.HTTPMethod {
        switch self {
            case .get: return Alamofire.HTTPMethod.get
            case .post: return Alamofire.HTTPMethod.post
            case .delete: return Alamofire.HTTPMethod.delete
            case .put: return Alamofire.HTTPMethod.put
        }
    }
}

enum APIParameterType {
    case url
    case urlEncodedInURL
    case json
}

class APIRequest {
    // MARK: - Variables and Types
    // MARK: Protected
   
    var methodType: APIRequestType = .get
    
    var type: APIRequestType {
        return self.methodType
    }
    
    var paramsType: APIParameterType {
        switch self.type {
        case .post, .put, .delete:
            return .json
            
        case .get:
            return .url
        }
    }
    
    var url: String {
        return ""
    }
    
    var params: [String: Any]? {
        return nil
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var responseKeyPath: String {
        return ""
    }
}
