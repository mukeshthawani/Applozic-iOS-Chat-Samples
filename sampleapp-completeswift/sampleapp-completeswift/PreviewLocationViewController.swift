//
//  PreviewLocationViewController.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import GoogleMaps

final class PreviewLocationViewController: ShareLocationBaseViewController {
    
    private var locationPreviewModel:LocationPreviewViewModel?
    
    override var isObserveMyLocation: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAddress()
    }
    
    override func navigateToEntryPoint() {
        
        guard let loc = locationPreviewModel else {return}
        let coor = loc.coordinate
        animateAndDefaultZoom(toLocation: coor)
    }
    
    func setLocationViewModel(location:LocationPreviewViewModel) {
        locationPreviewModel = location
    }
    
    private func initializeAddress() {
        guard let loc = locationPreviewModel else {return}
        
        let coor = loc.coordinate
        let marker = GMSMarker(position: coor)
        marker.map = mapView
        marker.title = loc.addressText
        marker.icon = UIImage(named: "icon_share_location")
        
        mapView.selectedMarker = marker
    }
    
    @IBAction private func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
