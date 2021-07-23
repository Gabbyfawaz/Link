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
    private let image: UIImage

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Link Location"
        view.addSubview(mapView)
        
        let searchVC = SearchMapViewController()
        searchVC.delegate = self
        
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))

    }
    
    //MARK: - Init
    
    init(image: UIImage) {
        self.image = image
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
        
//        guard let coordinates = self.coordinates, let locationTitle = self.locationTitle else {return}
        navigationController?.pushViewController(CreateLinkViewController(image: image, locationTitle: locationTitle, coordinates: coordinates), animated: true)
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


