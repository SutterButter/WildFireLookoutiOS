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

class Fire: NSObject {
    var maxLat: Double
    var minLat: Double
    var maxLon: Double
    var minLon: Double
    var latest: String
    var docID: String
    
    init(fire: [String: Any], id: String) {
        maxLat = fire["MaxLat"] as? Double ?? 0.0
        minLat = fire["MinLat"] as? Double ?? 0.0
        maxLon = fire["MaxLon"] as? Double ?? 0.0
        minLon = fire["MinLon"] as? Double ?? 0.0
        latest = fire["Latest"] as? String ?? ""
        docID = id
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Fire {
            return maxLat == object.maxLat && minLat == object.minLat && maxLon == object.maxLon && minLon == object.minLon && latest == object.latest
        } else {
            return false
        }
    }
}

class Perimeter {
    var acres: Double
    var agency: String
    var comments: String
    var complexName: String
    var dateTime: Date
    var epochTime: Double
    var fireCode: String
    var fireName: String
    var location: GeoPoint
    var points: [GeoPoint]
    var uniqueFireIdentifier: String
    var unitIdentifier: String
    
    init(perimeter: [String: Any]) {
        acres = perimeter["Acres"] as? Double ?? 0.0
        agency = perimeter["Agency"] as? String ?? ""
        comments = perimeter["Comments"] as? String ?? ""
        complexName = perimeter["ComplexName"] as? String ?? ""
        dateTime = perimeter["DateTime"] as? Date ?? Date()
        epochTime = perimeter["EpochTime"] as? Double ?? 0.0
        fireCode = perimeter["FireCode"] as? String ?? ""
        fireName = perimeter["FireName"] as? String ?? ""
        location = perimeter["Location"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        points = perimeter["Points"] as? [GeoPoint] ?? [GeoPoint]()
        uniqueFireIdentifier = perimeter["UniqueFireIdentifier"] as? String ?? ""
        unitIdentifier = perimeter["UnitIdentifier"] as? String ?? ""
    }
}

class MapsViewController: UIViewController, GMSMapViewDelegate {
    
    var loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var fires = [Fire]()
    var fetchedFires = [Fire]()
    var perimeters = [Perimeter]()
    
    var db:Firestore? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil) { // a user is signed in, do nothing
                print("USER SIGNED IN")
            } else { // no user signed in, go back to login screen
                print("NO USER SIGNED IN")
                self.performSegue(withIdentifier: "mapsToSignInSegue", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let w = view.frame.width
        // Get Current Location
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        var lat: Double = 36.778259
        var lon: Double = -119.417931
        if let location = locationManager.location {
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Add Activity Indicator
        loadingIndicator.frame = CGRect(x: w / 2.0, y: 50, width: 20.0, height: 20.0)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        view.addSubview(loadingIndicator)
        view.bringSubviewToFront(loadingIndicator)
        
        
        
        
        
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        
        db = Firestore.firestore()
        
        loadFireMetadata()
        fetchFirePerimeters(mapView: mapView)
    }
    
    func loadFireMetadata() {
        // Get all potential fire perimeters
        loadingIndicator.startAnimating()
        db!.collection("fires")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let fire = Fire(fire: document.data(), id: document.documentID)
                        self.fires.append(fire)
                        print("Loaded: \(document.documentID) => \(document.data())")
                    }
                }
                self.loadingIndicator.stopAnimating()
        }
    }
    
    func geoPointToCLLPoint(point: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: point.latitude)!, longitude: CLLocationDegrees(exactly: point.longitude)!)
    }
    
    func fetchFirePerimeters(mapView: GMSMapView) {
        // Getting corner lat/lons which we will use to specify which perimeters to load
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
        
        // Find which fire to fetch
        var firesToFetch = [Fire]()
        for fire in self.fires {
            // if (RectA.Left < RectB.Right && RectA.Right > RectB.Left &&
            //     RectA.Top > RectB.Bottom && RectA.Bottom < RectB.Top )
            // if the above is true than the two rects are intersecting
            if (minLon < fire.maxLon && maxLon > fire.minLon && maxLat > fire.minLat && minLat < fire.maxLat) {
                firesToFetch.append(fire)
            }
        }
        
        // Fetch the needed fires
        for fire in firesToFetch {
            // Only fetch the fire if we have not done so before
            if !fetchedFires.contains(fire) && fire.latest != "" {
                print("Getting a new fire.")
                loadingIndicator.startAnimating()
                let docRef = db!.collection("fires/" + fire.docID + "/perimeters/").document(fire.latest)
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        // Get the perimeter
                        let perimeter = Perimeter(perimeter: document.data()!)
                        self.perimeters.append(perimeter)
                        
                        // Add the perimeter
                        let path = GMSMutablePath()
                        for point in perimeter.points {
                            let coord = self.geoPointToCLLPoint(point: point)
                            path.add(coord)
                        }
                        let polygon = GMSPolygon(path: path)
                        polygon.fillColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.25)
                        polygon.strokeColor = .red
                        polygon.strokeWidth = 2
                        polygon.map = mapView
                        
                        // Add a point for the main part of the fire perimeter
                        let position = perimeter.location
                        let firePoint = GMSMarker(position: self.geoPointToCLLPoint(point: position))
                        firePoint.title = perimeter.fireName + " Fire"
                        //firePoint.icon = UIImage(named: "fire_perimeter_small")
                        firePoint.icon = GMSMarker.markerImage(with: .red)
                        firePoint.map = mapView
                        
                        print("Fetched document: \(fire.latest) for fire: \(perimeter.fireName)")
                        self.fetchedFires.append(fire) // making sure the fire is not loaded again
                    } else {
                        print("Document does not exist")
                    }
                    self.loadingIndicator.stopAnimating()
                }
            }
        }
    }
    
    // Called when the user stops moving the map
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("Idle, attempting to add new fires.")
        fetchFirePerimeters(mapView: mapView)
    }


}

