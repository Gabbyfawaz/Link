//
//  BoomingAnnotationView.swift
//  Link
//
//  Created by Gabriella Fawaz on 22/03/2022.
//

import UIKit
import MapKit
import UberRides




class BoomingAnnotationView: MKMarkerAnnotationView {

    
    
    override var annotation: MKAnnotation? { didSet { configureDetailView() } }
    private let manager = CLLocationManager()
    private var coordinates: CLLocationCoordinate2D?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
        getCurrentLocation()
    }
    
    func getCurrentLocation() {
            // Ask for Authorisation from the User.
            self.manager.requestAlwaysAuthorization()

            // For use in foreground
            self.manager.requestWhenInUseAuthorization()

            if CLLocationManager.locationServicesEnabled() {
                manager.delegate = self
                manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                manager.requestLocation()
            }
        }

}

 extension BoomingAnnotationView: CLLocationManagerDelegate {
   
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.coordinates = locations.last?.coordinate
        
    }
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("Error: \(error.localizedDescription)")
     }
}

private extension BoomingAnnotationView {
    
    func configure() {
        canShowCallout = true
        configureDetailView()
    }

    func configureDetailView() {
        guard (annotation as? BoomingAnnotation) != nil else { return }

        let rect = CGRect(origin: .zero, size: CGSize(width: 160, height: 105))

        let boomingView = UIView()
        boomingView.translatesAutoresizingMaskIntoConstraints = false

//        let options = MKMapSnapshotter.Options()
//        options.size = rect.size
//        options.mapType = .satelliteFlyover
//        options.camera = MKMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 250, pitch: 65, heading: 0)

        
        let bView = BoomingView(frame: rect)
        bView.delegate = self
        boomingView.addSubview(bView)
//        let snapshotter = MKMapSnapshotter(options: options)
//
//        snapshotter.start { snapshot, error in
//            guard let snapshot = snapshot, error == nil else {
//                print(error ?? "Unknown error")
//                return
//            }
//
//            let bView = BoomingView(frame: rect)
////            let imageView = UIImageView(frame: rect)
////            imageView.image = snapshot.image
//            boomingView.addSubview(bView)
//        }

        detailCalloutAccessoryView = boomingView
        NSLayoutConstraint.activate([
            boomingView.widthAnchor.constraint(equalToConstant: rect.width),
            boomingView.heightAnchor.constraint(equalToConstant: rect.height)
        ])
    }
}

extension BoomingAnnotationView:BoomingViewDelegate {
    func boomingViewDidTapUber(_ view: BoomingView, coordinates: CLLocationCoordinate2D, locationTitle: String) {
        guard let usersLatitude = self.coordinates?.latitude,
              let userLongitude = self.coordinates?.longitude else {
                  return
              }
        let usersLocationTitle = "Home"
        let latitude2 = coordinates.latitude
        let longitude2 = coordinates.longitude

        let builder = RideParametersBuilder()
        let pickupLocation = CLLocation(latitude: usersLatitude, longitude: userLongitude)
        let dropoffLocation = CLLocation(latitude: latitude2, longitude: longitude2)
        builder.pickupNickname = usersLocationTitle
        builder.pickupLocation = pickupLocation
        builder.dropoffLocation = dropoffLocation
        builder.dropoffNickname = locationTitle
        builder.dropoffAddress = locationTitle
        let rideParameters = builder.build()

        let deeplink = RequestDeeplink(rideParameters: rideParameters, fallbackType: .appStore)
        deeplink.execute()
    }
    
    func boomingViewDidTapMaps(_ view: BoomingView, coordinates: CLLocationCoordinate2D, locationTitle: String) {
        print("Did tap maps again")
        let regionDistance:CLLocationDistance = 10000
        let coordinates = coordinates
       let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(locationTitle)"
        mapItem.openInMaps(launchOptions: options)
    }
    
    func boomingDidPin(_ view: BoomingView, coordinates: CLLocationCoordinate2D, locationTitle: String) {
        DatabaseManager.shared.addUserToBommingPin(locationTitle: locationTitle) { success in
            if success {
                print("Added users yayy")
            } else {
                print("No user added")
            }
        }
    }
    
    
}
