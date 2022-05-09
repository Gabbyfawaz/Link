//
//  BoomingAnnotationView.swift
//  Link
//
//  Created by Gabriella Fawaz on 22/03/2022.
//

import UIKit
import MapKit

class BoomingAnnotationView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? { didSet { configureDetailView() } }

    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
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
