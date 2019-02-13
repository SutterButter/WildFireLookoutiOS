//
//  FirstViewController.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 2/8/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import Mapbox

class FirstViewController: UIViewController, MGLMapViewDelegate {

    var first = true
    var mapView: MGLMapView!
    var contoursLayer: MGLStyleLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: 39.8475, longitude: -121.395), zoomLevel: 4, animated: false)
        view.addSubview(mapView)
        
        
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {

        let source = MGLVectorTileSource(identifier: "testLayer", configurationURL: URL(string: "mapbox://nsutter.FirePoints")!)
        
        
        let layer = MGLCircleStyleLayer(identifier: "testLayer", source: source)
        layer.sourceLayerIdentifier = "FirePoints"
        layer.circleColor = NSExpression(forConstantValue: #colorLiteral(red: 0.67, green: 0.28, blue: 0.13, alpha: 1))
        layer.circleOpacity = NSExpression(forConstantValue: 0.8)
        
        
        style.addSource(source)
        style.addLayer(layer)
    }
}

