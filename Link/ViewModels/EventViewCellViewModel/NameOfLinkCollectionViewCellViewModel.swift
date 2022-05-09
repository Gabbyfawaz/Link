//
//  PosterLinkCollectionViewCellViewModel.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation


enum NameOfLinkCollectionCellViewActions {
    case request(isRequested: Bool)
    case accept(isAccepted: Bool)
}
struct NameOfLinkCollectionViewCellViewModel {
    
    let linkType: String
    let profilePictureURL: URL?
    let userArray: [SearchUser]
    let actionButton: NameOfLinkCollectionCellViewActions?
    
}
