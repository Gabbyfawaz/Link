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
}
