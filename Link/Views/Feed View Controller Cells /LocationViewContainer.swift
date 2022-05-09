//
//  LocationViewContainer.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/31.
//

import UIKit
import CoreLocation
import MapKit
import TinyConstraints
import UberRides


protocol LocationViewContainerDelegate: AnyObject {
    func locationViewContainerDidTapAppleMaps(_ view: LocationViewContainer, options:[String : NSValue], mapItem: MKMapItem )
    func locationViewContainerDidTapUber(_ view: LocationViewContainer, deepLink: RequestDeeplink)

}

class LocationViewContainer: UIView, CLLocationManagerDelegate, MKMapViewDelegate {
    
    weak var delegate: LocationViewContainerDelegate?
    private var isCustumViewHidden = true
    private let mapIdentifier = "mapIdentifier"
    private var longitude: CLLocationDegrees?
    private var latitude: CLLocationDegrees?
    private var usersLongitude: CLLocationDegrees?
    private var usersLatitude: CLLocationDegrees?
    private var usersLocationTitle: String?
    private let locationManager = CLLocationManager()
    private var distanceBetweenPoints: CLLocationDistance?

    private let userIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 22.5
        iv.frame.size = CGSize(width: 45, height: 45)
//        iv.layer.borderWidth = 2
//        iv.layer.borderColor = UIColor.white.cgColor
//        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private let linkIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 22.5
        iv.frame.size = CGSize(width: 45, height: 45)
//        iv.layer.borderWidth = 2
//        iv.layer.borderColor = UIColor.white.cgColor
//        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private var  stackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    private let appleMaps: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "maps"), for: .normal)
        return button
    }()
    
    private let uberButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "uber"), for: .normal)
        return button
    }()
    
//    private let timeAwayLabel: UILabel = {
//        let label = UILabel()
//        label.text = "10mins"
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = .systemFont(ofSize: 10, weight: .bold)
//        label.layer.masksToBounds = true
//        label.layer.cornerRadius = 8
//        label.backgroundColor = .black
//        return label
//    }()
    
    private let DistanceAwayLabel: UILabel = {
        let label = UILabel()
        label.text = "15km"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.backgroundColor = .black
        return label
    }()
    
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "LOCATION"
        label.textColor =  .label
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    private let locationButton: UIButton = {
        let button = UIButton()
        button.setImage( UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .light
        return map
    }()
    
    private let locationlabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    private var locationTitle: String?
    
     let customLocationView = CustomLocationPopUp()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = .systemBackground

        addSubview(mapView)
        addSubview(titleLabel)
        addSubview(locationButton)
//        ddSubview(locationlabel)
        addSubview(stackView)
        addSubview(customLocationView)
        
        customLocationView.isHidden = true
        customLocationView.delegate = self
        
        
        stackView.addArrangedSubview(uberButton)
//        stackView.addArrangedSubview(timeAwayLabel)
        stackView.addArrangedSubview(appleMaps)
        stackView.addArrangedSubview(DistanceAwayLabel)
        

        locationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
        
        getCurrentLocation()
        appleMaps.addTarget(self, action: #selector(didTapGoogleMaps), for: .touchUpInside)
      
        
        uberButton.addTarget(self, action: #selector(didTapUber), for: .touchUpInside)
      
        

    }
    
    required init?(coder: NSCoder) {
        fatalError()
        }

    //MARK: - Actions
   
        override func layoutSubviews() {
            super.layoutSubviews()
            
            
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(x: 20,
                                      y: 0,
                                      width: 150,
                                      height: titleLabel.height)
            locationButton.frame = CGRect(x: width-35 , y: 5, width: 20, height: 20)
            mapView.frame = CGRect(x: 15,
                                   y: 40,
                                   width: width-30,
                                   height:200)
        
            
            stackView.frame = CGRect(x: width-30-45,
                                     y: locationButton.bottom+(40),
                                     width: 50,
                                     height: 150)
            
           

            
            customLocationView.frame = CGRect(x: (mapView.right-customLocationView.width)/2,
                                              y: mapView.top + (mapView.height-100)/2,
                                              width: width-150,
                                              height: 80)
            
            
        }
    
    //MARK: - Actions
    
    @objc func didTapUber() {
        
        guard let latitude = self.latitude,
              let longitude = self.longitude,
              let locationTitle = self.locationTitle,
              let usersLatitude = self.usersLatitude,
              let userLongitude = self.usersLongitude,
              let usersLocationTitle = self.usersLocationTitle else {
                  return
              }

        let builder = RideParametersBuilder()
        let pickupLocation = CLLocation(latitude: usersLatitude, longitude: userLongitude)
        let dropoffLocation = CLLocation(latitude: latitude, longitude: longitude)
        builder.pickupNickname = usersLocationTitle
        builder.pickupLocation = pickupLocation
        builder.dropoffLocation = dropoffLocation
        builder.dropoffNickname = locationTitle
        builder.dropoffAddress = locationTitle
        let rideParameters = builder.build()

        let deeplink = RequestDeeplink(rideParameters: rideParameters, fallbackType: .appStore)
//        deeplink.execute()
        delegate?.locationViewContainerDidTapUber(self, deepLink: deeplink)
        
    }
    
    @objc func didTapGoogleMaps() {
        
       
            
        guard let latitude = self.latitude, let longitude = self.longitude, let locationTitle = self.locationTitle else {
            return
        }
        
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(locationTitle)"
        
        delegate?.locationViewContainerDidTapAppleMaps(self, options: options, mapItem: mapItem)
        
        
    }
    
    
    @objc func didTapLocationButton() {

//       isCustumViewHidden = !isCustumViewHidden
//        print("This button has been tapped!")
        
        customLocationView.isHidden = false
        
        
    }
    

    //MARK: - MapViewFunctions
    
    
    func getCurrentLocation() {
            // Ask for Authorisation from the User.
            self.locationManager.requestAlwaysAuthorization()

            // For use in foreground
            self.locationManager.requestWhenInUseAuthorization()

            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.requestLocation()
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.last
        guard let lat = location?.coordinate.latitude,
        let lon = location?.coordinate.longitude, let latitude = self.latitude, let longitude = self.longitude  else {return}
        
        self.usersLatitude = lat
        self.usersLongitude = lon
        let coordinates = CLLocation(latitude: lat, longitude: lon)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(coordinates) { (placemarks, error) in
            if error != nil {
                print("something went horribly wrong")
            }
            if let placemarks = placemarks {
                self.usersLocationTitle = placemarks.first?.name
            }
        }
        
        let sourceLocation = CLLocationCoordinate2D(latitude: lat , longitude: lon)
        let destinationLocation = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
        let sourceCoordinate = CLLocation(latitude: lat, longitude: lon)
        let destinationCoordinate = CLLocation(latitude: latitude, longitude: longitude)

        let distanceBetweenPoints = sourceCoordinate.distance(from: destinationCoordinate)/1000
        let roundedDistance = Int(distanceBetweenPoints)
        DistanceAwayLabel.text = "\(roundedDistance) KM"
      
        let sourcePin = MKPointAnnotation()
        sourcePin.coordinate = sourceLocation
        let destinationPin = MKPointAnnotation()
        destinationPin.coordinate = sourceLocation

        self.mapView.addAnnotation(sourcePin)
        self.mapView.addAnnotation(destinationPin)
        
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }
            
            let route = directionResonse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
        self.mapView.delegate = self



    }
    

    
    
    // MARK: - MKMapViewDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ooops sorry error occured!")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case let polyline as MKPolyline:
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor =  .black
            renderer.lineWidth = 5
            return renderer

        // you can add more `case`s for other overlay types as needed

        default:
            fatalError("Unexpected MKOverlay type")
        }
    }
   

    

    
    private func createUniqueAnnotation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let pin  = MKPointAnnotation()
        pin.coordinate = coordinates
          self.mapView.addAnnotation(pin)
        print("Created a new pin!")
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: mapIdentifier)

        if annotationView == nil {
            //create the view
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: mapIdentifier)

        } else {
            annotationView?.annotation = annotation
        }
        

        guard let latitude = self.latitude, let longitude = self.longitude else {
            return nil
        }
        
        let linkCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude )
        
        let annoationCoords = annotation.coordinate.latitude
        if annoationCoords == linkCoordinate.latitude {
            annotationView?.addSubview(linkIconImageView)
        } else {
            annotationView?.addSubview(userIconImageView)
        }
      
       
//        annotationView?.contentMode = .scaleAspectFill
//        annotationView?.frame.size = CGSize(width: 45, height: 45)
            

        return annotationView
    }

    
    //MARK: - ConfigureUI
    

    func configure(with viewModel: PostOfFeedCollectionViewModel) {
        

        
        if let distance = self.distanceBetweenPoints {
            let distanceAwayInt = Int(distance)
            DistanceAwayLabel.text = "\(distanceAwayInt) km"
        }
       
        
        
        locationlabel.text = "\(viewModel.locationTitle ?? "")"
        guard let locationString = viewModel.locationTitle else {
            return
        }
        
        customLocationView.configure(locationString: locationString, isPrivate: viewModel.isPrivate)
        
        
        StorageManager.shared.profilePictureURL(for: viewModel.username, completion: { url in
            
            guard let url = url else {
                return
            }
            self.userIconImageView.sd_setImage(with: url, completed: nil)
            
            self.linkIconImageView.sd_setImage(with: viewModel.linkTypeImage, completed: nil)
        })
        
        
        if viewModel.isPrivate == true {
            locationlabel.text = "Private"
        }

        guard let latitude = viewModel.coordinates.latitude, let longitude = viewModel.coordinates.longitude else {return}
        createUniqueAnnotation(latitude:latitude , longitude: longitude)
        
        
        self.latitude = viewModel.coordinates.latitude
        self.longitude = viewModel.coordinates.longitude
        self.locationTitle = viewModel.locationTitle
    }


    }


extension LocationViewContainer: CustomLocationPopUpDelegate {
    
    func customLocationPopUpDidTapCancel(_ view: CustomLocationPopUp) {
        customLocationView.isHidden = true
    }
    
    
}
