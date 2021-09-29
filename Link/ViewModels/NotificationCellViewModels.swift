//
//  NotificationCellViewModels.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation

struct LikeNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let postUrl: URL
    let date: String
}

struct FollowNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let isCurrentUserFollowing: Bool
    let date: String
}

struct CommentNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let postUrl: URL
    let date: String
    
}
/// add requestViewModel
    
struct AcceptNotificationCellViewModel: Equatable {
    let username: String
    let linkIconPictureUrl: URL
    let isCurrentInGuestInvited: Bool
    let postUrl: URL
    let date: String
    let postId: String
}

struct RequestNotificationCellViewModel: Equatable {
    let username: String
    let linkIconPictureUrl: URL
    let isRequested: Bool
    let postUrl: URL
    let date: String
    let postId: String
}

struct AcceptedRequestNotificationCellViewModel: Equatable {
    let username: String
    let linkIconPictureUrl: URL
    let isCurrentInGuestInvited: Bool
    let postUrl: URL
    let date: String
    let postId: String
}
