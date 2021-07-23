//
//  MapCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation

import UIKit
import MapKit
import CoreLocation
import SDWebImage
import GeoFire


protocol MapCollectionViewCellDelegate: AnyObject {
    func mapCollectionViewCellDidTapInfoOnAnnotation(_ vc: MapCollectionViewCell, post: LinkModel, owner: String )
}

class MapCollectionViewCell: UICollectionViewCell, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //MARK: - Properties
    
    var delegate: MapCollectionViewCellDelegate?
    static let identifier = "MapCollectionViewCell"
    private let mapIdentifier = "mapAnnotation"
    private var allLinks: [(link: LinkModel, owner: String)] = []
    private var observer: NSObjectProtocol?
    private var index = 0
    

    private var currentLocation: CLLocationCoordinate2D?
//    private var linkType: String?
//    private var linkInfo: String?
//    private var linkTypeImage: String?
//    private var coordinates: CLLocationCoordinate2D?
    
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        return image
    }()

    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = .standard
        mapView.tintColor = .purple
        return mapView
    }()
    
    private let defaultLocation = CLLocationCoordinate2D(latitude: -26.270760, longitude: 28.112268)
    
    
    public var viewContainer =  HomeMapViewContainer()
    
 
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubview(mapView)
        contentView.addSubview(viewContainer)
        
//        mapView.centerToLocation(defaultLocation)
//        moveCameraToLocation()
        
        mapView.setRegion(MKCoordinateRegion(center: defaultLocation,
                                         span: MKCoordinateSpan(
                                            latitudeDelta: 0.8,
                                            longitudeDelta: 0.8)), animated: false)
        mapView.delegate = self
//        addCustomPin()
        
        
        fetchAllLinks()
        observer = NotificationCenter.default.addObserver(
            forName: .didPostLinkOnMap,
            object: nil,
            queue: .main
        ) { [weak self] _ in
//            self?.postViewModels.removeAll()
            self?.fetchAllLinks()
        }


    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    //MARK: - LayoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mapView.frame = contentView.bounds
        let sizeHeight = contentView.height/4
//        mapViewOG.bringSubviewToFront(viewContainer)
        viewContainer.frame = CGRect(x: (contentView.width-60), y: contentView.width-200, width: 50, height: sizeHeight)

    }

 //MARK: - ConfigureUI
    
//    public func configure(linkId: String) {
//
//        guard let username = UserDefaults.standard.string(forKey: "username") else {
//            return
//
//        }
//
//        if linkId != "" {
//            DatabaseManager.shared.getLink(with: linkId, from: username, completion: { [weak self] linkModel in
//
//
//                  guard let linkType = linkModel?.linkTypeName,
//                   let linkInfo = linkModel?.info,
//                   let linkTypeImage = linkModel?.linkTypeImage,
//                   let latitude = linkModel?.location.latitude,
//                   let longitude = linkModel?.location.longitude
//                   else { return }
//
//
//
//
//
//
//
//
//                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
//
//                // mark custom pin
//                let pin  = MKPointAnnotation()
//                pin.coordinate = coordinates
//                pin.title = linkType
//                pin.subtitle = linkInfo
//                self?.mapView.addAnnotation(pin)
//
//
//                })
//            }
//
//
//        }
//
    
    private func fetchAllLinks() {
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
            
        }
        let userGroup = DispatchGroup()
        userGroup.enter()

        var allLinks: [(link: LinkModel, owner: String)] = []

        DatabaseManager.shared.following(for: username) { usernames in
            defer {
                userGroup.leave()
            }

            let users = usernames + [username]
            for current in users {
                userGroup.enter()
                DatabaseManager.shared.getAllLinks(for: current) { result in
                    DispatchQueue.main.async {
                        defer {
                            userGroup.leave()
                        }

                        switch result {
                        case .success(let links):
                            allLinks.append(contentsOf: links.compactMap({
                                (link: $0, owner: current)
                            }))

                        case .failure:
                            break
                        }
                    }
                }
            }
        }

        userGroup.notify(queue: .main) {
            let group = DispatchGroup()
            self.allLinks = allLinks
            print("allLinks: \(allLinks)")
            allLinks.forEach { model in
                group.enter()
            // add annotations
                
                guard let latitude = model.link.location.latitude, let longitude = model.link.location.longitude else {return}
                
                self.createUniqueAnnotation(
            linkType: model.link.linkTypeName,
            linkInfo: model.link.info,
            linkTypeImage: model.link.linkTypeImage,
            latitude: latitude,
            longitude: longitude)
                
//                self.selectedPin(with: model.link.id)
                
            }

            group.notify(queue: .main) {
//                self.sortData()
//                self.LinkPostCollectionView?.reloadData()
            }
        }
    }

    
    private func createUniqueAnnotation(linkType: String, linkInfo: String, linkTypeImage: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let pin  = MKPointAnnotation()
        pin.coordinate = coordinates
        pin.title = linkType
        pin.subtitle = linkInfo
          self.mapView.addAnnotation(pin)
        print("Created a new pin!")
        
    }
    
  
    
    
//MARK: - Custom Annotation
    
//    private func addCustomPin() {
//
//        print("Coodinates: \(self.coordinates)")
//        guard let location = self.coordinates else {return}
//        let pin  = MKPointAnnotation()
//        pin.coordinate = location
//        pin.title = self.linkType
//        pin.subtitle = self.linkInfo
//        self.mapView.addAnnotation(pin)
//
//    }

    // customising now
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: mapIdentifier)

        if annotationView == nil {
            //create the view
            let mapsButton = UIButton(type: .detailDisclosure)
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: mapIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = mapsButton
            mapsButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

        } else {
            annotationView?.annotation = annotation
        }
        
   
        
//        let index = annotationView?.index(ofAccessibilityElement: annotation)
//
//        print("print index: \(index)")
        

        annotationView?.image = UIImage(named: "ball")
        annotationView?.frame = CGRect(x: 0, y: 0, width: 50, height: 60)
        return annotationView
    }

    
    
    @objc private func didTapButton() {
        
        let tuple = allLinks[index]
        delegate?.mapCollectionViewCellDidTapInfoOnAnnotation(self, post: tuple.link, owner: tuple.owner)
        
//        print("didTapButton")
//        let tuple = allLinks[index]
//        HapticManager.shared.vibrateForSelection()
//        let vc = PostViewController(post: tuple.post, owner: tuple.owner)
//        vc.title = "Post"
        
//        delegate?.mapCollectionViewCell(self, index: index, tuple: tuple)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func selectedPin(with linkId: String) {
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // do something

//        selectedPin(with:  )
        print("Selected map icon!")
        let annotation = view.annotation
        let index = (self.mapView.annotations as NSArray).index(of: annotation)
        print ("Annotation Index = \(index)")
        self.index = index
    }

    
    
//MARK: - Map Actions

private func usersCurrentLocation() {
    // Ask for Authorisation from the User.
    let locationManager = CLLocationManager()
    locationManager.requestAlwaysAuthorization()

    // For use in foreground
    locationManager.requestWhenInUseAuthorization()

    if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }

    currentLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
}
    

//func moveCameraToLocation() {
//    let region = MKCoordinateRegion(
//        center:  defaultLocation.coordinate,
//      latitudinalMeters: 50000,
//      longitudinalMeters: 60000)
//    mapView.setCameraBoundary(
//      MKMapView.CameraBoundary(coordinateRegion: region),
//      animated: true)
//
//    let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
//    mapView.setCameraZoomRange(zoomRange, animated: true)
//
//}

}


//MARK: - CenterToLocation

//private extension MKMapView {
//func centerToLocation(
//_ location: CLLocationCoordinate2D,
//regionRadius: CLLocationDistance = 1000
//) {
//let coordinateRegion = MKCoordinateRegion(
//  center: location,
//  latitudinalMeters: regionRadius,
//  longitudinalMeters: regionRadius)
//setRegion(coordinateRegion, animated: true)
//}
//}

