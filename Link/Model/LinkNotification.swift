//
//  LinkNotification.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation

struct LinkNotification: Codable {
    let identifer: String
    let notificationType: Int // 1: like, 2: comment, 3: follow
    let username: String
    let dateString: String
    var isFollowing: [Bool?]
    var isRequesting: [Bool?]
    let postId: String?
    let postUrl: String

}

