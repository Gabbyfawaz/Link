//
//  PostLocationCollectionViewCellViewModel.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation


struct PostLocationCollectionViewCellViewModel {
    let location: String?
    let isPrivate: Bool
    let coordinates: Coordinates
    let user: String
    let postLinkIcon: String
}
