//
//  LinkHomeCellViewModelType.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation

enum LinkHomeCellViewModelType {
    case poster(viewModel: PosterLinkCollectionViewCellDelegate)
    case post(viewModel: PostLinkCollectionViewCellViewModel)
    case actions(viewModel: PostLinkActionCollectionViewCellViewModel)
    case invite(viewModel: PostInviteCollectionViewCellViewModel)
    case info(viewModel: PostInfoCollectionViewCellViewModel)
    case location(viewModel: PostLocationCollectionViewCellViewModel)
    case logistic(viewModel: PostLogisticCollectionViewCellViewModel)
    case extraInfo(viewModel: PostLinkExtraInfoCollectionCellViewModel)
    case date(viewModel: PostLinkDateCollectionCellViewModel)
}
