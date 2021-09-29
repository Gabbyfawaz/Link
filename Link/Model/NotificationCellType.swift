//
//  NotificationCellType.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation

enum NotificationCellType {
    case follow(viewModel: FollowNotificationCellViewModel)
    case like(viewModel: LikeNotificationCellViewModel)
    case comment(viewModel: CommentNotificationCellViewModel)
    case accept(viewModel: AcceptNotificationCellViewModel)
    case request(viewModel: RequestNotificationCellViewModel)
    case acceptedRequest(viewModel: AcceptedRequestNotificationCellViewModel)
}

/// add a request cell type
