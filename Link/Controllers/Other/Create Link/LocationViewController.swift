//
//  LocationViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import MapKit
import FloatingPanel
import CoreLocation


//protocol LocationViewControllerDelegate: AnyObject {
//    func locationViewController(_ vc: LocationViewController, withCoords coordinates: CLLocationCoordinate2D?, withTitle title: String?)
//}

class LocationViewController: UIViewController, SearchMapViewControllerDelegate {
 
    
    //MARK: - Properties

//    weak var delegate: LocationViewControllerDelegate?
    private let mapView = MKMapView()
    let panel = FloatingPanelController()
//
    private var coordinates: CLLocationCoordinate2D?
    private var locationTitle: String?
    private let arrayOfImage: [UIImage]
    private let typeOfLink: String
    private let iconImage: UIImage
    private var resultsArray = [SearchResult]()
    private let caption: String

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Location"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        view.addSubview(mapView)
        
        let searchVC = SearchMapViewController()
        searchVC.delegate = self
        
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(didTapDone))
        
        publicLocationTitle = locationTitle ?? ""
        publicCoordinates = coordinates ?? CLLocationCoordinate2D()
            
    }
    
    //MARK: - Init
    
    init(arrayOfImage: [UIImage], typeOfLink:String, iconImage: UIImage, caption:String, locationTitle: String?, coordinates: CLLocationCoordinate2D?, guestInvited: [SearchResult]) {
        self.arrayOfImage = arrayOfImage
        self.typeOfLink = typeOfLink
        self.iconImage = iconImage
        self.caption = caption
        publicLocationTitle = locationTitle ?? ""
        publicCoordinates = coordinates ?? CLLocationCoordinate2D()
        publicGuestsInvited = guestInvited
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }
    
    //MARK: - Actions
    @objc private func didTapDone() {
        
        let vc = AddNewPeopleToLinkViewController(arrayOfImage: arrayOfImage, locationTitle: locationTitle, coordinates: coordinates, typeOfLink: self.typeOfLink, iconImage: iconImage, caption: self.caption, guestInvited: publicGuestsInvited)
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {return}
            strongSelf.resultsArray.append(contentsOf: result)
            print("results array: \(strongSelf.resultsArray)")
    }
        navigationController?.pushViewController(vc, animated: true)

    }
    
    //MARK: - SearchMapViewControllerDelegate
    
    func searchMapViewController(_ vc: SearchMapViewController, didSelectLocationWith coordinates: CLLocationCoordinate2D?, title: String?) {
        
        guard let coordinates = coordinates else {
            return
        }
        
        self.coordinates = coordinates
        
        guard let locationTitle = title else {
            return
        }
    
        self.locationTitle = locationTitle
    
        
//        delegate?.locationViewController(self, withCoords: coordinates, withTitle: locationTitle)
        
        panel.move(to: .tip, animated: true)
        mapView.removeAnnotations(mapView.annotations)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        
        mapView.setRegion(MKCoordinateRegion(center: coordinates,
                                             span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)),
                          animated: true)
    }
    

}


