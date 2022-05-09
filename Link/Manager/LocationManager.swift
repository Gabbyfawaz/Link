//
//  LocationManager.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation
import CoreLocation


class LocationManager: NSObject {
    static let shared = LocationManager()
    
    
//    public func findLocation(with query: String, completion: @escaping([LocationMaps])-> Void) {
//        
//        let geoCoder = CLGeocoder()
//        geoCoder.geocodeAddressString(query, completionHandler: { places, error in
//            guard let places = places, error == nil else {
//                completion([])
//                return
//            }
//            
//            let models: [LocationMaps] = places.compactMap({ place in
//                var name = ""
//                if let locationName = place.name {
//                    name += locationName
//                }
//                if let adminRegion = place.administrativeArea {
//                    name += ", \(adminRegion)"
//                }
//                if let locality = place.locality {
//                    name += ", \(locality)"
//                }
//                if let country = place.country {
//                    name += ", \(country)"
//                }
//                
//                print("This is the place: \(place)")
//                let result = LocationMaps(title: name,
//                                      coordinates: place.location?.coordinate)
//                return result
//                
//            })
//        completion(models)
//        })
//    }
}
