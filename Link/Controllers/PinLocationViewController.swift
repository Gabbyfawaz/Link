//
//  PinLocationViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/08/17.
//

import UIKit
import MapKit
import CoreLocation


class PinLocationViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating {

    
    
    //MARK: - Properties
    
    
    private let searchVC = UISearchController(searchResultsController: PinResultsLocationViewController())
    
    private let mapView = MKMapView()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Make It Boom"
        

        view.backgroundColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapDone))
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        view.addSubview(mapView)
//        searchBar.becomeFirstResponder()
    }
    
   //MARK: - LayoutSubviews
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapView.frame = view.bounds
//        mapView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height - view.safeAreaInsets.top)
    }
    
    
    //MARK: - Actions

    @objc func didTapDone() {

        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Seach Controller Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty, let resultsVC = searchController.searchResultsController as? PinResultsLocationViewController else {
            return
        }
        
        resultsVC.delegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            
            switch result {
            case .success(let places):
                print(places)
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    

}

extension PinLocationViewController: PinResultsLocationViewControllerDelegate {
    
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true, completion: nil)
        
        // remove all map pins
        
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        // add a map pin
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(
                            center: coordinates,
                            span: MKCoordinateSpan(latitudeDelta: 0.2,
                                                   longitudeDelta: 0.2)),
                          animated: true)
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        let boomingPin = Pin(name: username, cooordinates: Coordinate(latitude: coordinates.latitude, longitude: coordinates.longitude))
        
        DatabaseManager.shared.savePins(pinDrop: boomingPin) { (success) in
            if success {
                print("The coodinates have been saves to database")
            } else {
                print("Error saving pins to database")
            }
            
        }
        
    }
    
 
    
    
}
