//
//  ShareLocationViewController.swift
//  Axiata
//
//  Created by appsynth on 1/17/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Kingfisher
import Applozic

protocol ShareLocationViewControllerDelegate: class {
    func locationDidSelected(geocode: Geocode, image: UIImage)
}


final class ShareLocationViewController: ShareLocationBaseViewController {
    
    fileprivate var pinCoordinate: CLLocationCoordinate2D?
    
    weak var delegate: ShareLocationViewControllerDelegate?
    
    // shareLocation
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var shareLocationButton: UIButton!
    fileprivate var isLoading: Bool = true {
        willSet(newValue) {
             if newValue {
                shareLocationButton.isHidden = true
                activityIndicatorView.startAnimating()
            } else {
                shareLocationButton.isHidden = false
                activityIndicatorView.stopAnimating()
            }
        }
    }
    
    private func reverseGeocode(position: CLLocationCoordinate2D,
                                success: @escaping ([Geocode]) -> (),
                                failure: @escaping (Error?) -> ()) {
        
        let request = ReverseGeoCodeRequest()
        request.location = position

        API.requestForItems(request: request) { (geocodes: [Geocode]?, isCache, error) in
            
            if error != nil {
                failure(error)
                return
            }
            
            guard let geocodes = geocodes else {
                failure(nil)
                return
            }
            
            success(geocodes)
        }
    }

    private func createStaticMap(position: CLLocationCoordinate2D,
                                success: @escaping (UIImage) -> (),
                                failure: @escaping (Error?) -> ()) {
        guard let apiKey = ALUserDefaultsHandler.getGoogleMapAPIKey() else { return }
        var urlString: String? = "https://maps.googleapis.com/maps/api/staticmap?" +
            "markers=color:red|size:mid|\(position.latitude),\(position.longitude)" +
            "&zoom=15&size=237x102&maptype=roadmap&scale=2" +
            "&key=\(apiKey)"
        
        urlString = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        if let urlString = urlString, let url = URL(string: urlString) {
            
            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { (image: Image?, error: NSError?, cacheType: CacheType, url: URL?) in
            
//                Logger.verbose(message: "image: \(image) Error: \(error) cacheType: \(cacheType) url: \(url)")

                guard let image = image else {
                    failure(error)
                    return
                }
                success(image)
            }
        }
    }

    @IBAction func dismissTapped(_ sender: Any) {
       self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareLocationTapped(_ button: UIButton) {
        
        if isObserveMyLocation && isInitialLocationReceived(){
            isLoading = true
            
            guard let _ = pinCoordinate else {
//                view.makeToast(SystemMessage.Map.MapIsLoading, duration: 1.0, position: .center)
                return
            }
            
            guard let coor = pinCoordinate else {
                isLoading = false
                return
            }
            
//            Logger.verbose(message: "Select coor \(coor)")

            var geocode: Geocode?
            var locationImage: UIImage?
            
            let group = DispatchGroup()
            group.enter()
            group.enter()
            
            // get geocodes from googleAPI
            reverseGeocode(position: coor, success: {(geocodes) in
                geocode = geocodes.first
//                Logger.debug(message: "geocode: \(geocode) -> coor:\(coor)")
                group.leave()
                
            }, failure: { [weak self]  (error) in
                guard let weakSelf = self else {return}
//                Logger.error(message: "fail to reverse geocode \(error)")

                group.leave()
//                weakSelf.view.makeToast(SystemMessage.Map.MapIsLoading, duration: 1.0, position: .center)
            })
            
            // get location image from googleAPI
            createStaticMap(position: coor, success: { (image) in
                locationImage = image
                group.leave()
                
            }, failure: { (error) in
//                Logger.error(message: "fail to create static map \(error)")
                group.leave()
            })
            
            // pass value by delegate and dismiss on this page.
            group.notify(queue: DispatchQueue.main, execute: { [weak self] in
                guard let strongSelf = self,
                    let locationImage = locationImage,
                    let geocode = geocode else {
                        self?.isLoading = false
//                        Logger.error(message: "fail to reverse Geocode/locationImage")
//                        self?.view.makeToast(SystemMessage.Map.MapIsLoading, duration: 1.0, position: .center)
                        return
                }
                
                geocode.location = coor
                
                strongSelf.delegate?.locationDidSelected(geocode: geocode, image: locationImage)
                strongSelf.dismiss(animated: true, completion: {
                    self?.isLoading = false
                })
            })
        } else {
//            self.view.makeToast(SystemMessage.Map.NoGPS, duration: 1.0, position: .center)
        }
    }
}


// MARK: GMSMapViewDelegate
extension ShareLocationViewController {
    
    override func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        super.mapView(mapView, idleAt: position)
//        Logger.verbose(message: "position idleAt \(position)")
        pinCoordinate = position.target
    }
    
    override func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        super.mapViewDidFinishTileRendering(mapView)
        
        if isMapFinishLoading {
            isLoading = false
        } else {
            isLoading = true
        }
    }
}
