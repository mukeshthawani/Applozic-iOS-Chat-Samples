//
//  Geocode.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 07/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

import ObjectMapper
import CoreLocation
import GoogleMaps

final class Geocode: Mappable, CustomStringConvertible {
    static let defaultFormattedAddress = "-"
    
    var displayName: String         = defaultFormattedAddress
    var formattedAddress: String    = defaultFormattedAddress
    var placeIdentifier: String     = ""
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var addressComponents           = [[String: AnyObject]]()
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        displayName         <- map["formatted_address"]
        formattedAddress    <- map["formatted_address"]
        placeIdentifier     <- map["place_id"]
        location.latitude   <- map["geometry.location.lat"]
        location.longitude  <- map["geometry.location.lng"]
        addressComponents   <- map["address_components"]
    }
    
    var description: String {
        return "Geocode: \n displayName: \(displayName), \n formatted address: \(formattedAddress), \n placeIdentifier: \(placeIdentifier),  \n location: \(location)"
    }
}
