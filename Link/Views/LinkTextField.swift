//
//  IGTextField.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

class LinkTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        leftViewMode = .always
      layer.cornerRadius = 0
        layer.borderWidth = 1
        backgroundColor = .systemBackground
        layer.borderColor = UIColor.secondaryLabel.cgColor
        autocapitalizationType = .none
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

}

