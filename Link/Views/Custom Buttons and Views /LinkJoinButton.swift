//
//  LinkJoinButton.swift
//  Link
//
//  Created by Gabriella Fawaz on 16/03/2022.
//

import Foundation


import UIKit

final class LinkJoinButton: UIButton {

    enum State: String {
        case join = "Join"
        case joined = "Joined"


        var titleColor: UIColor {
            switch self {
            case .join: return .black
            case .joined: return .systemYellow
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .join: return .systemYellow
            case .joined: return .black
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
//        layer.cornerRadius = 4
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

     
    }
}


