//
//  MapViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 06/12/2021.
//


import UIKit
import MapKit

class MapViewController: UIViewController {
    
    private enum AnnotationReuseID: String {
        case pin
    }
    
  private var mapView = MKMapView()
    
    private var mapItems: [MKMapItem]?
    private var boundingRegion: MKCoordinateRegion?
    static var staticCoordinates: CLLocationCoordinate2D?
    static var staticLocationTitle: String?
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let vcs = self.navigationController?.viewControllers {
            let previousVC = vcs[vcs.count - 2]
            if previousVC is FinalPageCreateLinkViewController {
                navigationItem.rightBarButtonItem?.title = "Done"
            } 
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)

        if let region = boundingRegion {
            mapView.region = region
        }
        mapView.delegate = self
        
        // Show the compass button in the navigation bar.
        let compass = MKCompassButton(mapView: mapView)
        compass.compassVisibility = .visible
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: compass)
        mapView.showsCompass = false // Use the compass in the navigation bar instead.
        
        // Make sure `MKPinAnnotationView` and the reuse identifier is recognized in this map view.
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: AnnotationReuseID.pin.rawValue)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        guard let mapItems = mapItems else { return }
        
        if mapItems.count == 1, let item = mapItems.first {
            title = item.name
        } else {
            title = NSLocalizedString("TITLE_ALL_PLACES", comment: "All Places view controller title")
        }
        
        // Turn the array of MKMapItem objects into an annotation with a title and URL that can be shown on the map.
        let annotations = mapItems.compactMap { (mapItem) -> PlaceAnnotation? in
            guard let coordinate = mapItem.placemark.location?.coordinate else { return nil }
            
            let annotation = PlaceAnnotation(coordinate: coordinate)
            annotation.title = mapItem.name
            annotation.url = mapItem.url
            
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
    
    init(mapItems: [MKMapItem]?, boundingRegion: MKCoordinateRegion?) {
//        self.arrayOfImage = arrayOfImage
//        self.iconImage = iconImage
//        self.caption = caption
//        self.category = category
        self.mapItems = mapItems
        self.boundingRegion = boundingRegion
        super.init(nibName: nil, bundle: nil)
        
       
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
   
    @objc private func didTapDone() {
        
        if let vcs = self.navigationController?.viewControllers {
            let previousVC = vcs[vcs.count - 3]
            if previousVC is FinalPageCreateLinkViewController {
                
                guard let latitute = mapItems?[0].placemark.location?.coordinate.latitude, let longitude = mapItems?[0].placemark.location?.coordinate.longitude, let locationTitle = mapItems?[0].name else {fatalError("Could not extract data from map item")}
                
                let coordinates = CLLocationCoordinate2D(latitude: latitute, longitude: longitude)
                MapViewController.staticCoordinates = coordinates
                MapViewController.staticLocationTitle = locationTitle
                navigationController?.popViewController(animated: true)
                navigationController?.popViewController(animated: true)
                
            } else if previousVC is MapsViewController {
                dismiss(animated: true, completion: nil)
            }

            let previousVC2 = vcs[vcs.count - 2]
            if previousVC2 is SearchResultTableViewController {
                    guard let latitute = mapItems?[0].placemark.location?.coordinate.latitude, let longitude = mapItems?[0].placemark.location?.coordinate.longitude, let locationTitle = mapItems?[0].name else {fatalError("Could not extract data from map item")}
                    
                    let coordinates = CLLocationCoordinate2D(latitude: latitute, longitude: longitude)
                    
                    MapViewController.staticCoordinates = coordinates
                    MapViewController.staticLocationTitle = locationTitle
                    
                
                    
                    let vc = AddNewPeopleToLinkViewController()
            //        let vc = AddNewPeopleToLinkViewController(arrayOfImage: self.arrayOfImage, locationTitle: locationTitle , coordinates: coordinates, typeOfLink: self.category, iconImage: self.iconImage, caption: self.caption)
                    
                    navigationController?.pushViewController(vc, animated: true)
            }
            
            
           
            
        }
      
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapView.frame = view.bounds
    }
    
    
}

extension MapViewController: MKMapViewDelegate {
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("Failed to load the map: \(error)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PlaceAnnotation else { return nil }
        
        // Annotation views should be dequeued from a reuse queue to be efficent.
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationReuseID.pin.rawValue, for: annotation) as? MKMarkerAnnotationView
        view?.canShowCallout = true
        view?.clusteringIdentifier = "searchResult"
        
        // If the annotation has a URL, add an extra Info button to the annotation so users can open the URL.
        if annotation.url != nil {
            let infoButton = UIButton(type: .detailDisclosure)
            view?.rightCalloutAccessoryView = infoButton
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? PlaceAnnotation else { return }
        if let url = annotation.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
