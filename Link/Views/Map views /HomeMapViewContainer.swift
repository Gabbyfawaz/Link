//
//  HomeMapViewContainer.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

protocol HomeMapViewContainerProtocols: AnyObject {
    func homeMapViewContainerDidTapProfile(_ container: HomeMapViewContainer)
    func homeMapViewContainerDidTapNotifications(_ container: HomeMapViewContainer)
    func homeMapViewContainerDidTapPinLocation(_ container: HomeMapViewContainer)
    func homeMapViewContainerDidTapExplore(_ container: HomeMapViewContainer)
}

class HomeMapViewContainer: UIView {
    
    //MARK: - Properties
    
    weak var delegate: HomeMapViewContainerProtocols?
    
    private var  stackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
//        stack.layer.cornerRadius = 17.5
        return stack
    }()

    private let notificationsButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "suit.heart",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()

    private let profileButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "person.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()

//    private let createLinkButton: UIButton = {
//        let button = UIButton()
//        button.tintColor = .label
//        let image = UIImage(systemName: "plus",
//                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
//        button.setImage(image, for: .normal)
//        return button
//    }()
    
    private let exploreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "magnifyingglass",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let pinLocationButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "mappin.and.ellipse",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        button.setImage(image, for: .normal)
        return button
    }()
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        alpha = 0.3
        layer.cornerRadius = 8
        
        stackView.backgroundColor = UIColor(white: 1, alpha: 0.3)
        
//        addSubview(stackView)
        stackView.addArrangedSubview(exploreButton)
        stackView.addArrangedSubview(profileButton)
        stackView.addArrangedSubview(notificationsButton)
        stackView.addArrangedSubview(pinLocationButton)
//        addSubview(createLinkButton)
        
//        createLinkButton.addTarget(self, action: #selector(didTapCreateLink), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(didTapProfile), for: .touchUpInside)
        notificationsButton.addTarget(self, action: #selector(didTapNotifications), for: .touchUpInside)
        pinLocationButton.addTarget(self, action: #selector(didTapPinLocation), for: .touchUpInside)
        exploreButton.addTarget(self, action: #selector(didTapExplore), for: .touchUpInside)


        
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    //MARK: - Actions
    
//    @objc func didTapCreateLink() {
//        delegate?.homeMapViewContainerDidTapCreateLink(self)
//    }
    @objc func didTapExplore() {
        delegate?.homeMapViewContainerDidTapExplore(self)
    }
    @objc func didTapProfile() {
        delegate?.homeMapViewContainerDidTapProfile(self)
    }
    
    @objc func didTapNotifications() {
        delegate?.homeMapViewContainerDidTapNotifications(self)
    }
    
    @objc func didTapPinLocation() {
        delegate?.homeMapViewContainerDidTapPinLocation(self)
        
    }
    //MARK: - LayoutSubviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        let sizeButton: CGFloat = (height/4.2)
        stackView.frame = CGRect(x: 0, y: 0, width: sizeButton, height: height)
//
//        createLinkButton.frame = CGRect(x: 0, y: 1, width: sizeButton, height: sizeButton)
//        profileButton.frame = CGRect(x: 0, y: createLinkButton.bottom+1, width: sizeButton, height: sizeButton)
//        notificationsButton.frame = CGRect(x: 0, y: profileButton.bottom+1, width: sizeButton, height: sizeButton)
//        pinLocationButton.frame = CGRect(x: 0, y: notificationsButton.bottom+1, width: sizeButton, height: sizeButton)
//
  
    }
    
 

}
