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
import GeoFire
import Geofirestore
import MapKit

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

class FirePoint {
    var dateTime: Date
    var brightTI4: Double
    var brightTI5: Double
    var confidence: String
    var daynight: Bool
    var frp: Double
    var scan: Double
    var track: Double
    var type: String
    var location: GeoPoint
    var docId: String
    
    init(firePoint: [String: Any], id: String) {
        print(firePoint)
        dateTime = firePoint["D"] as? Date ?? Date()
        brightTI4 = firePoint["4"] as? Double ?? 0.0
        brightTI5 = firePoint["5"] as? Double ?? 0.0
        confidence = firePoint["C"] as? String ?? ""
        daynight = firePoint["N"] as? Bool ?? false // Day = False, Night = True
        frp = firePoint["R"] as? Double ?? 0.0
        scan = firePoint["S"] as? Double ?? 0.0
        track = firePoint["TR"] as? Double ?? 0.0
        type = firePoint["T"] as? String ?? ""
        location = firePoint["L"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
        docId = id
    }
}

struct markerKey {
    var key: String
}

class MapsViewController: UIViewController, GMSMapViewDelegate {
    
    var loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var fires = [Fire]()
    var fetchedFires = [Fire]()
    var perimeters = [Perimeter]()
    
    var db:Firestore? = nil
    
    var geoFirestore:GeoFirestore?
    var regionQuery:GFSRegionQuery?
    
    var states = ["CA", "TX", "FL"]
    var listeners = [ListenerRegistration]()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        
        // If signed in stay on the page if not go back to login
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
        
        
        
        // Get Current Location
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        var lat: Double = 32.301
        var lon: Double = -101.764
        if let location = locationManager.location {
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
        }
        
        // Set up the map view
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        
        // Add Activity Indicator over the map view (so we can see what is loading)
        let w = view.frame.width
        loadingIndicator.frame = CGRect(x: w / 2.0, y: 50, width: 20.0, height: 20.0)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        view.addSubview(loadingIndicator)
        view.bringSubviewToFront(loadingIndicator)
    
        // Get database from app delegate
        db = delegate.db
        
        // Load all the fires for future reference
        loadFireMetadata()
        // Get fire perimeters based on initial map size
        fetchFirePerimeters(mapView: mapView)
        
        getFirePoints(states: states, mapView: mapView)
        // Get firepoints
        
        
        
        
        
//        // Get all firepoints
//        print("Fetching Firepoints")
//        let geoFirestoreRef = Firestore.firestore().collection("firepoints")
//        geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        
        
        // Setting the firepoints region then defining what to do with documents
        //let region = getFirePointsRegion(mapView: mapView)
//        //regionQuery = geoFirestore?.query(inRegion: region)
//
//        print("Region Set")
//        print(region)
//
//        let _ = regionQuery!.observe(.documentEntered, with: { (key, location) in
//            print("GOT DOCUMENT!!!")
//            //print("The document with documentID '\(String(describing: key))' entered the search area and is at location '\(String(describing: location))'")
//
//            let firePoint = GMSMarker(position: location!.coordinate)
//            firePoint.title = "Fire Point"
//            if (key != nil) {
//                firePoint.userData = markerKey(key: key!)
//            }
//            //firePoint.icon = UIImage(named: "fire_perimeter_small")
//            firePoint.map = mapView
//        })
        
        print("Observe set")
    }
    
    func detatchListeners() {
        for listener in listeners {
            listener.remove()
        }
    }
    
    // Converts from a geopoint to a CLLocationCoordinate2D
    func geoPointToCLLPoint(point: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: point.latitude)!, longitude: CLLocationDegrees(exactly: point.longitude)!)
    }
    
    func getFirePoints(states: [String], mapView: GMSMapView) {
        var query = db!.collection("fp")
        for state in states {
            let listener: ListenerRegistration = query.whereField("state", isEqualTo: state)
                .addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    snapshot.documentChanges.forEach { diff in
                        
                        if (diff.type == .added) {
                            print("New state: \(diff.document.data())")
                            print("Added")
                            let data = diff.document.data()
                            let points = data["points"] as? [[String: Any]] ?? [[String: Any]]()
                            
                            for point in points {
                                print("Point")
                                var firePoint = FirePoint(firePoint: point, id: diff.document.documentID)
                                
                                // Add a point for the main part of the fire perimeter
                                let position = firePoint.location
                                
                                // lon is E/W
                                // Scan is E/W
                                // lat is N/S
                                // Track is N/S
                                let dxDegrees = firePoint.scan/(111.0 * cos(position.latitude)) // East-west distance in degrees
                                let dyDegrees = firePoint.track/111.0        // North-south distance in degrees
                                
                                let minLat = position.latitude - dyDegrees
                                let maxLat = position.latitude + dyDegrees
                                let minLon = position.longitude - dxDegrees
                                let maxLon = position.longitude + dxDegrees
                                
                                let v1 = CLLocationCoordinate2D(latitude: minLat, longitude: minLon)
                                let v2 = CLLocationCoordinate2D(latitude: minLat, longitude: maxLon)
                                let v3 = CLLocationCoordinate2D(latitude: maxLat, longitude: maxLon)
                                let v4 = CLLocationCoordinate2D(latitude: maxLat, longitude: minLon)
                                
                                
                                let path = GMSMutablePath()
                                path.add(v1)
                                path.add(v2)
                                path.add(v3)
                                path.add(v4)
                                
                                let polygon = GMSPolygon(path: path)
                                polygon.fillColor = UIColor(red: 1.0, green: 0.5, blue: 0, alpha: 0.25)
                                polygon.strokeColor = .orange
                                polygon.strokeWidth = 2
                                polygon.map = mapView
                                //{(f-df,l-dl), (f+df,l-dl), (f+df,l+dl), (f-df,l+dl)} // List of vertices
                                
                                
                                let fireMarker = GMSMarker(position: self.geoPointToCLLPoint(point: position))
                                fireMarker.title = "Fire"
                                //firePoint.icon = UIImage(named: "fire_perimeter_small")
                                fireMarker.icon = GMSMarker.markerImage(with: .orange)
                                fireMarker.map = mapView
                            }
                            
                            print("New state: \(diff.document.data())")
                        }
                        if (diff.type == .modified) {
                            //var firePoint = FirePoint(firePoint: diff.document.data(), id: diff.document.documentID)
                            print("Modified state: \(diff.document.data())")
                        }
                        if (diff.type == .removed) {
                            //var firePoint = FirePoint(firePoint: diff.document.data(), id: diff.document.documentID)
                            print("Removed state: \(diff.document.data())")
                        }
                    }
            }
            listeners.append(listener)
        }
        
        
    }
    
    // Loads data about the fires
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
    
    
    // Gets the current minimum and maximum longitudes for the map
    func getMinMaxLatLon(mapView: GMSMapView) -> (Double, Double, Double, Double)  {
        // Getting corner lat/lons which we will use to specify which perimeters to load
        let topLeft = mapView.projection.coordinate(for: CGPoint(x: 0, y: 0))
        let topRight = mapView.projection.coordinate(for: CGPoint(x: mapView.layer.frame.width, y: 0))
        let bottomRight = mapView.projection.coordinate(for: CGPoint(x: mapView.layer.frame.width, y: mapView.layer.frame.height))
        let bottomLeft = mapView.projection.coordinate(for: CGPoint(x: 0, y: mapView.layer.frame.height))
        
        let lats = [topLeft.latitude, topRight.latitude, bottomRight.latitude, bottomLeft.latitude]
        let lons = [topLeft.longitude, topRight.longitude, bottomRight.longitude, bottomLeft.longitude]
        
        let maxLat = lats.max() ?? -90.0
        let minLat = lats.min() ?? 90.0
        let maxLon = lons.max() ?? -180.0
        let minLon = lons.min() ?? 180.0
        
        print(maxLat)
        print(minLat)
        print(maxLon)
        print(minLon)
        
        return (maxLat, minLat, maxLon, minLon)
    }
    
    // Gets fire perimeters based on the current max and min lat/lon of the map
    func fetchFirePerimeters(mapView: GMSMapView) {
        // Getting corner lat/lons which we will use to specify which perimeters to load
        let (maxLat, minLat, maxLon, minLon) = getMinMaxLatLon(mapView: mapView)
        
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
                        firePoint.title = perimeter.fireName + "VIIRS Fire Point"
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
    // We update perimeters every time this happens
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //print("Idle, attempting to add new fires.")
        fetchFirePerimeters(mapView: mapView)
        //let region = getFirePointsRegion(mapView: mapView)
        //regionQuery?.region = region
    }
    
//    // When the user taps a marker we update it's information
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        marker.tracksInfoWindowChanges = true
//
//        //let mK = marker.userData! as! markerKey
//        //let key = mK.key
//        let docRef = db!.collection("firepoints").document(key)
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                // Get the perimeter
//                let firePoint = FirePoint(firePoint: document.data()!, id: "")
//                if (firePoint.type == "V") {
//                    marker.title = "VIIRS Fire Point"
//                } else {
//                    marker.title = "MODIS Fire Point"
//                }
//            } else {
//                print("Document does not exist")
//            }
//            marker.tracksInfoWindowChanges = false
//        }
//
//
//        return false
//    }

    // Gets a region to query
    func getFirePointsRegion(mapView: GMSMapView) -> MKCoordinateRegion {
        print("Querying for new points")
        
        // Getting corner lat/lons which we will use to specify which perimeters to load
        let (maxLat, minLat, maxLon, minLon) = getMinMaxLatLon(mapView: mapView)
        
        if ((maxLat == -180.0 && minLat == -180.0 && maxLon == -180.0 && minLon == -180.0) || (maxLat == -90.0 && minLat == 90.0 && maxLon == -180.0 && minLon == 180.0)) {
            let center = CLLocation(latitude: 36.7783, longitude: -119.4179)
            let span = MKCoordinateSpan(latitudeDelta: 0.0, longitudeDelta: 0.0)
            let region = MKCoordinateRegion(center: center.coordinate, span: span)
            return region
        }
        
        let latDelta = maxLat - minLat
        let lonDelta = maxLon - minLon
        
        let centerLat = minLat + (latDelta / 2.0)
        let centerLon = minLon + (lonDelta / 2.0)
        
        // Query using a region
        let center = CLLocation(latitude: centerLat, longitude: centerLon)
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region = MKCoordinateRegion(center: center.coordinate, span: span)
        print("returning region")
        return region
    }
}

