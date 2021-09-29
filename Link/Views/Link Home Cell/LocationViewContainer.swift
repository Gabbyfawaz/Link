//
//  LocationViewContainer.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/31.
//

import UIKit
import CoreLocation
import MapKit

class LocationViewContainer: UIView, CLLocationManagerDelegate, MKMapViewDelegate {
    
    private let mapIdentifier = "mapIdentifier"
    private var longitude: CLLocationDegrees?
    private var latitude: CLLocationDegrees?
    private let locationManager = CLLocationManager()
    private var distanceBetweenPoints: CLLocationDistance?

    private let userIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 22.5
        iv.frame.size = CGSize(width: 45, height: 45)
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private let linkIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 22.5
        iv.frame.size = CGSize(width: 45, height: 45)
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private var  stackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    private let googleMapsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "maps"), for: .normal)
        return button
    }()
    
    private let uberButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "uber"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        return button
    }()
    
    private let timeAwayLabel: UILabel = {
        let label = UILabel()
        label.text = "10mins"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.backgroundColor = .black
        return label
    }()
    
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
        label.textColor =  .black
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    
    private let locationImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "info.circle")
        iv.isUserInteractionEnabled = true
        iv.tintColor = .label
        return iv
    }()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    private let locationlabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = .white

        addSubview(mapView)
        addSubview(titleLabel)
        addSubview(locationImageView)
//        ddSubview(locationlabel)
        addSubview(stackView)
        
        stackView.addArrangedSubview(uberButton)
        stackView.addArrangedSubview(timeAwayLabel)
        stackView.addArrangedSubview(DistanceAwayLabel)
        stackView.addArrangedSubview(googleMapsButton)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapLocation))
        locationlabel.addGestureRecognizer(tap)
        getCurrentLocation()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
        }

    //MARK: - Actions
    
    @objc private func didTapLocation() {
        
    }

        override func layoutSubviews() {
            super.layoutSubviews()
            
            mapView.frame = CGRect(x: 15,
                                   y: 40,
                                   width: width-30,
                                   height:160)
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(x: 20,
                                      y: 0,
                                      width: width-30,
                                      height: titleLabel.height)
            
            stackView.frame = CGRect(x: 15,
                                     y: mapView.bottom+10,
                                     width: width-30,
                                     height: 40)
            
            locationImageView.frame = CGRect(x: width-30-locationImageView.width , y: 5, width: 20, height: 20)
//
//            locationlabel.frame = CGRect(x: locationImageView.right+10, y: stackView.bottom+10 , width: (width-locationImageView.width-10-15), height: 30)
            
          

            
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
//              guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//              print("locations = \(locValue.latitude) \(locValue.longitude)")
       
        
        
        
        
        let location = locations.last
        guard let lat = location?.coordinate.latitude,
        let lon = location?.coordinate.longitude, let latitude = self.latitude, let longitude = self.longitude  else {return}
        
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
            renderer.strokeColor =  #colorLiteral(red: 0.8822453618, green: 0.8364266753, blue: 0.9527176023, alpha: 1)
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
        
        print("distance away: \(self.distanceBetweenPoints)")
        
        if let distance = self.distanceBetweenPoints {
            let distanceAwayInt = Int(distance)
            DistanceAwayLabel.text = "\(distanceAwayInt) km"
        }
       
        
        
        locationlabel.text = "\(viewModel.location ?? "")"
        
        
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
    }


    }


