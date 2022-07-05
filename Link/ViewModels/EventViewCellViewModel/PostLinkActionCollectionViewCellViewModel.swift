//
//  PostLinkActionCollectionViewCellViewModel.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation

struct PostLinkActionCollectionViewCellViewModel {
    let username: String
    let linkId: String
    let isLiked: Bool
    let linkName: String
    let likers: [String]
    let comments: [Comment]
    let dateOfLink: TimeInterval
    let rating: [Double]
    let userWhoRated: [String]
}
