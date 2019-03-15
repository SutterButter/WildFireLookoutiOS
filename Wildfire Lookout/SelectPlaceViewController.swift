//
//  SelectPlaceViewController.swift
//  Wildfire Lookout
//
//  Created by Noah Sutter on 3/13/19.
//  Copyright © 2019 Noah Sutter. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol LocationSelectedDelegate: class {
    func locationSelected(location: CLLocationCoordinate2D, zoom: Float)
}

class SelectPlaceViewController: UIViewController {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var selectedLocation: GMSMarker?
    var locationSelected = false
    
    @IBOutlet weak var mapView: GMSMapView!
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: LocationSelectedDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // Get Current Location
        let locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        var lat: Double = 32.301
        var lon: Double = -101.764
        if let location = locationManager.location {
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15.0)
        mapView.camera = camera
        //mapView.isMyLocationEnabled = true
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        self.navigationItem.rightBarButtonItem = barButton
        
        mapView.delegate = self
        
        //let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        //self.mapView.addGestureRecognizer(longPressRecognizer)
        // Do any additional setup after loading the view.
    }
    
    @objc func infoButtonTapped() {
        //print("Tappe")
        let alert = UIAlertController(title: "Selecting a Location", message: "You can select a location for your alert by either searching for a location in the search bar or by long pressing at the desired location on the map. \n\n The alert will trigger if a fire point is detected within 30 miles of the selected location.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func saveButtonTapped() {
        // call this method on whichever class implements our delegate protocol
        if (selectedLocation != nil) {
            delegate?.locationSelected(location: selectedLocation!.position, zoom: mapView.camera.zoom)
            
            // go back to the previous view controller
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}

// Handle the user's selection.
extension SelectPlaceViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        // Moving back to the map view and the new location
        searchController?.isActive = false
        mapView.animate(to: GMSCameraPosition(target: place.coordinate, zoom: 15))
        
        // Adding a marker at that location
        mapView.clear()
        self.selectedLocation = GMSMarker(position: place.coordinate)
        self.selectedLocation!.title = "Selected Location"
        self.selectedLocation!.map = mapView
        
        // Adding the save button once location is selected
        if (!locationSelected) {
            let button = UIBarButtonItem(title: "Select", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonTapped))
            self.navigationItem.rightBarButtonItem = button
            locationSelected = true
        }
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

extension SelectPlaceViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        // Adding a marker at the long pressed location
        mapView.clear()
        self.selectedLocation = GMSMarker(position: coordinate)
        self.selectedLocation!.title = "Selected Location"
        self.selectedLocation!.map = mapView
        
        // Adding the save button once location is selected
        if (!locationSelected) {
            let button = UIBarButtonItem(title: "Select", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonTapped))
            self.navigationItem.rightBarButtonItem = button
            locationSelected = true
        }
    }
}
