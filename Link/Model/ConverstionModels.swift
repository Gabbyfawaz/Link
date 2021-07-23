//
//  ConverstionModels.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation


struct Conversations {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
