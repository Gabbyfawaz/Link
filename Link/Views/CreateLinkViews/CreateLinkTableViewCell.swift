//
//  CreateLinkTableViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/08/25.


import UIKit

class CreateLinkTableViewCell: UITableViewCell {
    
    static let identifier = "CreateLinkTableViewCell"
    
    private var specializedView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
    
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
       
    }
    
//    func configure(with view: UIView) {
//
//        self.specializedView = view
//    }
//
    


}
