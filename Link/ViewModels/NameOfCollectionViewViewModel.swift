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
    let linkType: String
    let linkTypeImage: URL?
    let mainImage: URL?
    let username: String
    let location: String?
    let invite: [SearchResult]
    let isPrivate: Bool
    let coordinates: Coordinates
    let date: String
}
