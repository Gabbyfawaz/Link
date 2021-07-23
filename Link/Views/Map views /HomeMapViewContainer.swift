//
//  HomeMapViewContainer.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

protocol HomeMapViewContainerProtocols: AnyObject {
    func homeMapViewContainerDidTapCreateLink(_ container: HomeMapViewContainer)
    func homeMapViewContainerDidTapLinkNotifications(_ container: HomeMapViewContainer)
    func homeMapViewContainerDidTapNotifications(_ container: HomeMapViewContainer)
    func homeMapViewContainerDidTapMessages(_ container: HomeMapViewContainer)
}

class HomeMapViewContainer: UIView {
    
    //MARK: - Properties
    
    weak var delegate: HomeMapViewContainerProtocols?

    private let notificationsButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "suit.heart",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()

    private let linkNotificationsButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "link",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()

    private let createLinkButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "plus",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let messageButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "paperplane.fill",
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
        addSubview(notificationsButton)
        addSubview(createLinkButton)
        addSubview(messageButton)
        addSubview(linkNotificationsButton)
        
        createLinkButton.addTarget(self, action: #selector(didTapCreateLink), for: .touchUpInside)
        linkNotificationsButton.addTarget(self, action: #selector(didTapLinkNotifications), for: .touchUpInside)
        notificationsButton.addTarget(self, action: #selector(didTapNotifications), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(didTapRefresh), for: .touchUpInside)

        
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    //MARK: - Actions
    
    @objc func didTapCreateLink() {
        delegate?.homeMapViewContainerDidTapCreateLink(self)
    }
    
    @objc func didTapLinkNotifications() {
        delegate?.homeMapViewContainerDidTapLinkNotifications(self)
    }
    
    @objc func didTapNotifications() {
        delegate?.homeMapViewContainerDidTapNotifications(self)
    }
    
    @objc func didTapRefresh() {
        delegate?.homeMapViewContainerDidTapMessages(self)
        
    }
    //MARK: - LayoutSubviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sizeButton: CGFloat = (height/4.2)
        
        createLinkButton.frame = CGRect(x: 0, y: 1, width: sizeButton, height: sizeButton)
        linkNotificationsButton.frame = CGRect(x: 0, y: createLinkButton.bottom+1, width: sizeButton, height: sizeButton)
        notificationsButton.frame = CGRect(x: 0, y: linkNotificationsButton.bottom+1, width: sizeButton, height: sizeButton)
        messageButton.frame = CGRect(x: 0, y: notificationsButton.bottom+1, width: sizeButton, height: sizeButton)
        
  
    }
    
    //MARK: - ConfigureUI
    func configure() {
      
       
    }

}
