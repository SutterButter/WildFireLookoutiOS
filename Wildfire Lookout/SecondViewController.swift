//
//  SecondViewController.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 2/8/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import GoogleMaps

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        let floor = 1
        
        // Implement GMSTileURLConstructor
        // Returns a Tile based on the x,y,zoom coordinates, and the requested floor
        let urls: GMSTileURLConstructor = {(x, y, zoom) in
            let url = "https://api.mapbox.com/v4/nsutter.FirePoints/\(zoom)/\(x)/\(y).vector.pbf"
            return URL(string: url)
        }
        
        // Create the GMSTileLayer
        let layer = GMSURLTileLayer(urlConstructor: urls)
        
        // Display on the map at a specific zIndex
        layer.zIndex = 100
        layer.map = mapView
        
    }


}

