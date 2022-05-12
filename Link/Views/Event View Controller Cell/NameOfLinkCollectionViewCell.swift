//
//  PosterlinkCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit


protocol NameOfLinkCollectionViewCellDelegate: AnyObject {
    func posterLinkCollectionViewCellDidTapRequest(_ cell: NameOfLinkCollectionViewCell, isRequested: Bool)
    func posterLinkCollectionViewCellDidTapAccept(_ cell: NameOfLinkCollectionViewCell, isAccepted: Bool)
    
}

final class NameOfLinkCollectionViewCell: UICollectionViewCell {
    static let identifier = "PosterlinkCollectionViewCell"

    //MARK: -  Properties
  
    private var isRequested = false
    private var isAccepted =  false
    
    weak var delegate: NameOfLinkCollectionViewCellDelegate?
    
    private let typeOfLink: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    private let requestButton: LinkRequestButton = {
        let button = LinkRequestButton()
        button.isHidden = true
        return button
    }()
    
    private let acceptButton: LinkAcceptButton = {
        let button = LinkAcceptButton()
        button.isHidden = true
        return button
    }()
    
    private var guestInvited:[SearchUser]?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
 
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 25
        contentView.backgroundColor = .systemBackground
        addAllSubviews()
        requestButton.addTarget(self, action: #selector(didTapRequest), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(didTapAccept), for: .touchUpInside)
//        isInvited()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Main Actions
    
    private func addAllSubviews() {
//        contentView.insertSubview(contentView, at: 1)
        contentView.addSubview(typeOfLink)
        contentView.addSubview(requestButton)
        contentView.addSubview(acceptButton)
        
//        contentView.insertSubview(contentView, at: 1)
    }
    
//    private func isInvited() {
//        guard let username = UserDefaults.standard.string(forKey: "username") else {
//            return
//        }
//        
//        
//        guard let guestInvited = self.guestInvited else {
//            return
//        }
//        
//        if guestInvited.contains(where: { $0.name == username }) {
//            acceptButton.isHidden = false
//            requestButton.isHidden = true
////            acceptButton.configure(for: isAccepted ? .accept : .accepted)
//        } else {
//            requestButton.isHidden = false
//            acceptButton.isHidden = true
////            requestButton.configure(for: isRequested ? .requesting : .request)
//        }
//    }
    
    //MARK: - Actions for buttons
    
    @objc private func didTapAccept() {
        delegate?.posterLinkCollectionViewCellDidTapAccept(self, isAccepted: isAccepted)
        isAccepted = !isAccepted
        acceptButton.configure(for: isAccepted ? .accepted : .accept)
//        NotificationCenter.default.post(name: .didUpdateAcceptButton, object: nil, userInfo: ["isAccepting" : isAccepted])
    }
    
    @objc private func didTapRequest() {
        delegate?.posterLinkCollectionViewCellDidTapRequest(self, isRequested: isRequested)
        isRequested = !isRequested
        requestButton.configure(for: isRequested ? .requesting : .request)
//        NotificationCenter.default.post(name: .didUpdateRequestButton, object: nil, userInfo: ["isRequesting" : isRequested])
    }
    
    private func configureButtons(viewModel: NameOfLinkCollectionViewCellViewModel) {
        
//        let button = NameOfLinkCollectionCellViewActions.request(isRequested: false)
        let button = viewModel.actionButton
        switch button {
        case .request(let isRequested):
            requestButton.isHidden = false
            self.isRequested = isRequested
            requestButton.configure(for: isRequested ? .requesting : .request)
        case .accept(let isAccepted):
            acceptButton.isHidden = false
            self.isAccepted = isAccepted
            acceptButton.configure(for: isAccepted ? .accepted : .accept)
        case .none:
            break
        }
    }
    
    
    
  
    //MARK: - LayoutSubviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

//        typeOfLink.sizeToFit()
        typeOfLink.frame = CGRect(
            x: 20,
            y: 20,
            width: width-50-120,
            height: 40
        )
        

        requestButton.frame = CGRect(x: typeOfLink.right+10, y: 20, width: 120, height: 30)
        acceptButton.frame = CGRect(x:typeOfLink.right+10, y: 20, width: 120, height: 30)

        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        typeOfLink.text = nil
    }
    
    
    
    //MARK: - ConfigureUI
    func configure(with viewModel: NameOfLinkCollectionViewCellViewModel) {
        
        typeOfLink.text = viewModel.linkType
        self.guestInvited = viewModel.userArray
//        print("The number of guests invited is: \(self.guestInvited)")
        configureButtons(viewModel: viewModel)

   
    }
    
}

