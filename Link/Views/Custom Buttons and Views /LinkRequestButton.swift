//
//  LinkRequestButton.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/09/06.
//

import UIKit

final class LinkRequestButton: UIButton {

    enum State: String {
        case request = "Request"
        case requesting = "Requesting"


        var titleColor: UIColor {
            switch self {
            case .request: return .systemBackground
            case .requesting: return .systemBackground
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .request: return .label
            case .requesting: return .quaternaryLabel
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
        case .request:
            layer.borderWidth = 0
        case .requesting:
            layer.borderWidth = 0
        }
    }
}



