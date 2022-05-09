//
//  LinkAcceptButton.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/09/05.
//

import UIKit

final class LinkAcceptButton: UIButton {

    enum State: String {
        case accept = "Accept"
        case accepted = "Accepted"


        var titleColor: UIColor {
            switch self {
            case .accepted: return .white
            case .accept: return .white
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .accepted: return .systemGreen
            case .accept: return .systemRed
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        layer.masksToBounds = true
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    public func configure(for state: State) {
        setTitle(state.rawValue, for: .normal)
        backgroundColor = state.backgroundColor
        setTitleColor(state.titleColor, for: .normal)

        switch state {
        case .accepted:
            layer.borderWidth = 0
        case .accept:
            layer.borderWidth = 0
            layer.borderColor = UIColor.secondarySystemBackground.cgColor
        }
    }
}


