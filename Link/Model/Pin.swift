//
//  Pins.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/08/18.
//

import Foundation
import CoreLocation

struct Pin: Codable {
    let people: [SearchUser]
    let cooordinates: Coordinate
    let locationString: String
    let timeStamp: TimeInterval
    
}

struct Coordinate: Codable {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
}
