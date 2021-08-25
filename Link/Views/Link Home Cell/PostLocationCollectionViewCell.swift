//
//  PostLocationCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import MapKit
import CoreLocation

protocol PostLocationCollectionViewCellDelegate: AnyObject {
    func postLocationCollectionViewCellDidTapLocation(_ cell: PostLocationCollectionViewCell, index: Int)
}


final class PostLocationCollectionViewCell: UICollectionViewCell, CLLocationManagerDelegate, MKMapViewDelegate {
    static let identifier = "PostLocationCollectionViewCell"
    
    weak var delegate: PostLocationCollectionViewCellDelegate?

    var index = 0
    let mapIdentifier = "mapAnnotation"
    
    private var longitude: CLLocationDegrees?
    private var latitude: CLLocationDegrees?
    private var username: String?
    private let locationManager = CLLocationManager()

    private let imageView: UIImageView = {
        let iv = UIImageView()
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
//        button.setTitle("Maps", for: .normal)
//        button.setTitleColor(.black, for: .normal)
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
//        label.layer.borderWidth = 2
//        label.layer.borderColor = UIColor.black.cgColor
//        label.backgroundColor = .black
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
//        label.layer.borderWidth = 2
//        label.layer.borderColor = UIColor.black.cgColor
//        label.backgroundColor = .black
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.backgroundColor = .black
        return label
    }()
    
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "LOCATION"
        label.textColor =  .black
        label.font = .systemFont(ofSize: 21, weight: .bold)
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
        map.layer.masksToBounds = true
        map.layer.cornerRadius = 8
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
        backgroundColor = .systemBackground

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
            
            locationImageView.frame = CGRect(x: width-15-20 , y: 5, width: 20, height: 20)
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
    

//        func configure(with viewModel: PostOfFeedCollectionViewModel) {
//
//            locationlabel.text = "\(viewModel.location ?? "")"
//
//
//        }
//
    func configure(with viewModel: PostLocationCollectionViewCellViewModel) {
        locationlabel.text = "\(viewModel.location ?? "")"
        
        self.username = viewModel.user
        
        if viewModel.isPrivate == true {
            locationlabel.text = "Private"
        }

        guard let latitude = viewModel.coordinates.latitude, let longitude = viewModel.coordinates.longitude else {return}
        createUniqueAnnotation(latitude:latitude , longitude: longitude)
        
        
        self.latitude = viewModel.coordinates.latitude
        self.longitude = viewModel.coordinates.longitude
    }


    
}
