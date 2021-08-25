//
//  IGFollowButton.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

final class LinkFollowButton: UIButton {

    enum State: String {
        case follow = "Follow"
        case unfollow = "Unfollow"

        var titleColor: UIColor {
            switch self {
            case .follow: return .white
            case .unfollow: return .label
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .follow: return #colorLiteral(red: 0.2593106031, green: 0.06400629878, blue: 0.2692499161, alpha: 1)
            case .unfollow: return #colorLiteral(red: 0.7336848447, green: 0.2839495122, blue: 0.8180974961, alpha: 1)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    public func configure(for state: State) {
        setTitle(state.rawValue, for: .normal)
        backgroundColor = state.backgroundColor
        setTitleColor(state.titleColor, for: .normal)

        switch state {
        case .follow:
            layer.borderWidth = 0
        case .unfollow:
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.secondaryLabel.cgColor
        }
    }
}

