//
//  SingleLinkHomeCellViewModelType.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation

enum SingleLinkPostCellViewModelType {
    case poster(viewModel: PosterLinkCollectionViewCellViewModel)
    case post(viewModel: PostLinkCollectionViewCellViewModel)
    case actions(viewModel: PostLinkActionCollectionViewCellViewModel)
    case info(viewModel: PostLinkExtraInfoCollectionCellViewModel)
    case invite(viewModel: PostInviteCollectionViewCellViewModel)
    case location(viewModel: PostLocationCollectionViewCellViewModel)
    case logistic(viewModel: PostLogisticCollectionViewCellViewModel)
//    case extraInfo(viewModel: PostLinkExtraInfoCollectionCellViewModel)
    case date(viewModel: PostLinkDateCollectionCellViewModel)
    
}

enum SingleLinkFeedCellViewModelType {
        case nameOfLink(viewModel: PostOfFeedCollectionViewModel)
//    case nameOfLink(viewModel: NameOfCollectionViewViewModel)
//    case location(viewModel: PostLocationCollectionViewCellViewModel)
//    case invites(viewModel: PostInviteCollectionViewCellViewModel)
}
