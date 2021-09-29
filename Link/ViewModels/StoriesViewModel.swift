//
//  StoriesViewModel.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation
import UIKit

struct StoriesViewModel {
    let stories: [Story]
}

struct Story {
    let username: String
    let image: UIImage?
}



struct StoriesLinkModel {
    let stories: [LinkStory]
}

struct LinkStory: Codable {
    let linkStoryUrlString: String
    let isRequest: Bool?
    let id: String
    let username: String
}
