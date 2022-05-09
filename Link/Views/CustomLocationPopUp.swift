//
//  CustomLocationPopUp.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/09/02.
//

import UIKit

protocol CustomLocationPopUpDelegate: AnyObject {
    func customLocationPopUpDidTapCancel(_ view: CustomLocationPopUp)
}

class CustomLocationPopUp : UIView {
    
    
    weak var delegate: CustomLocationPopUpDelegate?

    private let title: UILabel = {
        let title = UILabel()
        title.text = "Event's Location:"
        title.textAlignment = .left
        title.textColor = .label
        title.font = .systemFont(ofSize: 18, weight: .semibold)
        return title
    }()
    
    private let locationTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .left
        title.textColor = .label
        title.font = .systemFont(ofSize: 16, weight: .medium)
        return title
    }()
    
    
    private let cancelButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "multiply.circle"), for: .normal)
        button.tintColor = .label
        return button
    }()
   
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        layer.masksToBounds = true
        layer.cornerRadius = 10
        addSubview(title)
        addSubview(locationTitle)
        addSubview(cancelButton)
        
        cancelButton.addTarget(self, action: #selector(didCancelButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        title.frame = CGRect(x: 15,
                             y: 5,
                             width: width-15-45,
                             height: 30)
        cancelButton.frame = CGRect(x: width-45,
                             y: 5,
                             width: 30,
                             height: 30)
        locationTitle.frame = CGRect(x: 15,
                                     y: title.bottom,
                             width: width-15,
                             height: 30)
        
    }
    
    
    @objc func didCancelButton() {
        
        delegate?.customLocationPopUpDidTapCancel(self)
    }
    
    
    public func configure(locationString: String, isPrivate: Bool) {
        locationTitle.text = locationString
        print("The location is: \(locationString)")
        
        if isPrivate == true {
            locationTitle.text = "Private"
        } 
    }
    
   
    
}
