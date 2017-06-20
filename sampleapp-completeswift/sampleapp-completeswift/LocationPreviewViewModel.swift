//
//  LocationPreviewViewModel.swift
//  Axiata
//
//  Created by appsynth on 1/24/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationPreviewViewModel {
    
    private var address: String
    private var coor: CLLocationCoordinate2D
    
    var addressText: String {
        get {
            return address
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coor
        }
    }
    
    var isReady: Bool {
        get {
            return addressText != SystemMessage.UIError.unspecifiedLocation
        }
    }
    
    init(geocode: Geocode) {
        self.init(addressText:  geocode.displayName, coor: geocode.location)
    }
    
    init(addressText: String, coor: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude)) {
        self.address    = addressText
        self.coor       = coor
    }
}
