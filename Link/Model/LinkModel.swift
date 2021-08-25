//
//  LinkModel.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation
import CoreLocation

struct LinkModel: Codable {
    
    let id: String
    let user: String
    let info: String
    let location: Coordinates
    let locationTitle: String?
    let linkTypeName: String
    var invites: [SearchResult]
    let postedDate: String
    let linkDate: String
    let postUrlString: String
    var likers: [String]
    var isPrivate: Bool
    var linkTypeImage: String
    let extraInformation: String
    

    var date: Date {
        guard let date = DateFormatter.formatter.date(from: postedDate) else { fatalError() }
        return date
    }
    
    var storageReference: String? {
        guard let username = UserDefaults.standard.string(forKey: "username") else { return nil }
        return "\(username)/link/\(id).png"
    }

}

struct Coordinates: Codable {
    let latitude: CLLocationDegrees?
    let longitude: CLLocationDegrees?
}


