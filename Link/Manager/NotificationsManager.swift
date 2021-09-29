//
//  NotificationsManager.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation

final class NotificationsManager {
    static let shared = NotificationsManager()

    enum linkType: Int {
        case like = 1
        case comment = 2
        case follow = 3
        case accept = 4
        case request = 5
        case accepetedRequest = 6 
    }

    private init() {}

    public func getNotifications(
        completion: @escaping ([LinkNotification]) -> Void
    ) {
        DatabaseManager.shared.getNotifications(completion: completion)
    }

    static func newIdentifier() -> String {
        let date = Date()
        let number1 = Int.random(in: 0...1000)
        let number2 = Int.random(in: 0...1000)
        return "\(number1)_\(number2)_\(date.timeIntervalSince1970)"
    }

    public func create(
        notification: LinkNotification,
        for username: String
    ) {
        let identifier = notification.identifer
        guard let dictionary = notification.asDictionary() else {
            return
        }
        DatabaseManager.shared.insertNotification(
            identifer: identifier,
            data: dictionary,
            for: username
        )
    }
}
