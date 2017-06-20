//
//  ReverseGeoCodingRequest.swift
//  Axiata
//
//  Created by appsynth on 1/19/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import UIKit
import CoreLocation
import Applozic

class ReverseGeoCodeRequest: APIRequest {
    
    var location: CLLocationCoordinate2D?
    
    override var url: String {
        return "https://maps.googleapis.com/maps/api/geocode/json"
    }
    
    override var params: [String: Any]? {
        if let l = location {
            guard let apiKey = ALUserDefaultsHandler.getGoogleMapAPIKey() else { return nil }
            let latlng = "\(l.latitude),\(l.longitude)"
            return ["latlng": latlng,
                    "key": apiKey]
                    //"language": "th"]
        }
        return nil
    }
    
    override var responseKeyPath: String {
        return "results"
    }
}
