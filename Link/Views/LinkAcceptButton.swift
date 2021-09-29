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
            case .accepted: return .black
            case .accept: return .white
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .accepted: return .secondarySystemBackground
            case .accept: return .red
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
        case .accepted:
            layer.borderWidth = 0
        case .accept:
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.secondarySystemBackground.cgColor
        }
    }
}


