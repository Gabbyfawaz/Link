//
//  SettingsModels.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation
import UIKit

struct SettingsSection {
    let title: String
    let options: [SettingOption]
}

struct SettingOption {
    let title: String
    let image: UIImage?
    let color: UIColor
    let handler: (() -> Void)
}

