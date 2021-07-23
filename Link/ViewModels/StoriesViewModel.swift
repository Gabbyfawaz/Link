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
