//
//  LocationPickerViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import CoreLocation
import MapKit



final class LocationPickerViewController: UIViewController {

    private let locationManager = CLLocationManager()
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    private var coordinates: CLLocationCoordinate2D?
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
//    private var isPickable = true
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()

    init(coordinates: CLLocationCoordinate2D?) {
        self.coordinates = coordinates
//        self.isPickable = coordinates == nil
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(map)
        view.backgroundColor = .systemBackground
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.requestWhenInUseAuthorization()
           locationManager.requestLocation()
        let locationSearchTable =  LocationSearchTable()
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.searchController = resultSearchController
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        locationSearchTable.mapView = map
        locationSearchTable.handleMapSearchDelegate = self
//        if isPickable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(sendButtonTapped))
//            map.isUserInteractionEnabled = true
//            let gesture = UITapGestureRecognizer(target: self,
//                                                 action: #selector(didTapMap(_:)))
//            gesture.numberOfTouchesRequired = 1
//            gesture.numberOfTapsRequired = 1
//            map.addGestureRecognizer(gesture)
//        }
//        else {
//            // just showing location
//            guard let coordinates = self.coordinates else {
//                return
//            }
//
//            // drop a pin on that location
//            let pin = MKPointAnnotation()
//            pin.coordinate = coordinates
//            map.addAnnotation(pin)
////        }
//        view.addSubview(map)
    }

    @objc func sendButtonTapped() {
        guard let coordinates = coordinates else {
            return
        }
        
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }

//    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
//        let locationInView = gesture.location(in: map)
//        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
//        self.coordinates = coordinates
//
//        for annotation in map.annotations {
//            map.removeAnnotation(annotation)
//        }
//
//        // drop a pin on that location
//        let pin = MKPointAnnotation()
//        pin.coordinate = coordinates
//        map.addAnnotation(pin)
//    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }

}


extension LocationPickerViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
//            self.coordinates = location.coordinate
//            print("The coordinates: \(coordinates)")
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
              let region = MKCoordinateRegion(center: location.coordinate, span: span)
              map.setRegion(region, animated: true)
          }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
}

extension LocationPickerViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        
        selectedPin = placemark
        // clear existing pins
//        map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        annotation.subtitle = placemark.formattedAddress
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        map.addAnnotation(annotation)
        self.coordinates = placemark.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        map.setRegion(region, animated: true)
    }
}
