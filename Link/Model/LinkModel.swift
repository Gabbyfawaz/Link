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
    var pending: [SearchUser]
    var accepted: [SearchUser]
    var requesting: [SearchUser]
    let postedDate: TimeInterval
    let linkDate: TimeInterval
    let postArrayString: [String]
    var likers: [String]
    var isPrivate: Bool
    var linkTypeImage: String
    let extraInformation: String
    

    var storageReference: String? {
        guard let username = UserDefaults.standard.string(forKey: "username") else { return nil }
        return "\(username)/link/\(id).png"
    }
    


}

public struct Coordinates: Codable {
    let latitude: CLLocationDegrees?
    let longitude: CLLocationDegrees?
}


