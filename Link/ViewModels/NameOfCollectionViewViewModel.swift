//
//  NameOfCollectionViewViewModel.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation

struct NameOfCollectionViewViewModel {
    let linkType: String
    let linkTypeImage: URL?
    let username: String
}


struct PostOfFeedCollectionViewModel {
    let linkId: String
    let linkType: String
    let linkTypeImage: URL?
    let mainImage: [String]?
    let username: String
    let locationTitle: String?
    let pendingUsers: [SearchUser]
    let confirmedUsers: [SearchUser]
    let isPrivate: Bool
    let coordinates: Coordinates
    let date: TimeInterval
    let actionButton: NameOfLinkCollectionCellViewActions
}
