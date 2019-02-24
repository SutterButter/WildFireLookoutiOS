//
//  SecondViewController.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 2/8/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseAuth
import FirebaseFirestore

var handle: AuthStateDidChangeListenerHandle?

class Fire {
    var maxLat: Double
    var minLat: Double
    var maxLon: Double
    var minLon: Double
    
    init(fire: [String: Any]) {
        maxLat = fire["MaxLat"] as? Double ?? 0.0
        minLat = fire["MinLat"] as? Double ?? 0.0
        maxLon = fire["MaxLon"] as? Double ?? 0.0
        minLon = fire["MinLon"] as? Double ?? 0.0
    }
}

class MapsViewController: UIViewController {

    var gMaxLat = -90.0
    var gMinLat = 90.0
    var gMaxLon = -180.0
    var gMinLon = 180.0
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil) { // a user is signed in
                print("USER SIGNED IN")
            } else { // no user signed in
                print("NO USER SIGNED IN")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        
        
        let topLeft = mapView.projection.coordinate(for: CGPoint(x: 0, y: 0))
        let topRight = mapView.projection.coordinate(for: CGPoint(x: mapView.layer.frame.width, y: 0))
        let bottomRight = mapView.projection.coordinate(for: CGPoint(x: mapView.layer.frame.width, y: mapView.layer.frame.height))
        let bottomLeft = mapView.projection.coordinate(for: CGPoint(x: 0, y: mapView.layer.frame.height))
        
        let lats = [topLeft.latitude, topRight.latitude, bottomRight.latitude, bottomLeft.latitude]
        let lons = [topLeft.longitude, topRight.longitude, bottomRight.longitude, bottomLeft.longitude]
        
        let maxLat = lats.max() ?? -90
        let minLat = lats.min() ?? 90
        let maxLon = lons.max() ?? -180
        let minLon = lons.min() ?? 180
        
        if (maxLat > gMaxLat) {
            gMaxLat = maxLat
        }
        if (minLat < gMinLat) {
            gMinLat = minLat
        }
        if (maxLon > gMaxLon) {
            gMaxLon = maxLon
        }
        if (minLon < gMinLon) {
            gMinLon = minLon
        }
        // if (RectA.Left < RectB.Right && RectA.Right > RectB.Left &&
        //     RectA.Top > RectB.Bottom && RectA.Bottom < RectB.Top )
        // if the above is true than the two rects are intersecting

        
        db.collection("fires")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var fires = [Fire]()
                    for document in querySnapshot!.documents {
                        let fire = Fire(fire: document.data())
                        fires.append(fire)
                        print("\(document.documentID) => \(document.data())")
                    }
                }
        }
//        db.collection("fires")
//            .whereField("MinLon", isLessThanOrEqualTo: maxLon)
//            .whereField("MaxLon", isGreaterThanOrEqualTo: minLon)
//            .whereField("MaxLat", isGreaterThanOrEqualTo: minLat)
//            .whereField("MinLat", isLessThanOrEqualTo: maxLat)
//            .getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                } else {
//                    for document in querySnapshot!.documents {
//                        print("\(document.documentID) => \(document.data())")
//                    }
//                }
//        }
//
        
        

        let perimeter = GMSMutablePath()
        //perimeter.add(<#T##coord: CLLocationCoordinate2D##CLLocationCoordinate2D#>)
        
        
    }


}

