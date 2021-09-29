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
    let profilePictureUrl: String
    let postLinkIconImage: String
    let username: String
    let dateString: String
    // Follow/Unfollow
    let isFollowing: Bool?
    let isAccepted : Bool?
    // Like/Comment
    let postId: String?
    let postUrl: String?

}

