//
//  MarkerInfoWindowView.swift
//  Axiata
//
//  Created by Mo on 3/27/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import UIKit
import GoogleMaps

final class MarkerInfoWindowView: UIView {

    // MARK: - Declare Variables or Types
    // MARK: Content
    @IBOutlet weak var addressLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Method of class
    func updateContent(marker: GMSMarker) {
        addressLabel.text = marker.title
        layoutIfNeeded()
    }
}
