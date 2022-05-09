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
        case requested = "Requested"

        var titleColor: UIColor {
            switch self {
            case .follow: return .systemBackground
            case .unfollow: return .label
            case .requested: return .white
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .follow: return .label
            case .unfollow: return .secondarySystemBackground
            case .requested: return .blue
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
        case .requested:
            layer.borderWidth = 0
        }
    }
}

