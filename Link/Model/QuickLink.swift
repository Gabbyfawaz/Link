//
//  LinkStory.swift
//  Link
//
//  Created by Gabriella Fawaz on 28/02/2022.
//

import UIKit
import CoreLocation

struct QuickLink: Codable {
    let id: String
    let username: String
    let timestamp: TimeInterval?
    let imageUrlString: String?
    let locationTitle: String?
    let locationCoodinates: Coordinates?
    let info: String?
    let xPosition: CGFloat
    let yPosition: CGFloat
    let height: CGFloat
    let date: TimeInterval
    var joined: [SearchUser]
//    let isRequest: Bool?
}
