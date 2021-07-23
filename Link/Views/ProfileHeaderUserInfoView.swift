//
//  ProfileHeaderUserInfoView.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit


protocol ProfileHeaderUserInfoViewDelegate: AnyObject{
    func profileHeaderUserInfoViewDidTapProfilePicture(_ view: ProfileHeaderUserInfoView)
}


class ProfileHeaderUserInfoView: UIView {
    
    weak var delegate: ProfileHeaderUserInfoViewDelegate?
    
    
    public let countContainerView = ProfileHeaderCountView()

    private let bioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40
        iv.backgroundColor = .white
        return iv
    }()
    
    private var maskImageView: UIImageView = {
        let maskImageView = UIImageView()
        maskImageView.contentMode = .scaleAspectFit
        maskImageView.image = #imageLiteral(resourceName: "mask")
        return maskImageView
    }()


    // Count Buttons

   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 1, alpha: 0.2)
//        backgroundColor = .black
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        
        addSubview(nameLabel)
        addSubview(bioLabel)
        addSubview(imageView)
        addSubview(countContainerView)
        
       
    }

    required init?(coder: NSCoder) {
        fatalError()
    }


    // Actions
//    @objc func didTapImage() {
//        delegate?.profileHeaderCollectionReusableViewDidTapProfilePicture(self)
//    }
//

    override func layoutSubviews() {
        super.layoutSubviews()
//        let buttonWidth: CGFloat = (width-15)/3
        
        
        imageView.frame = CGRect(x: 10, y: 10, width: 80, height: 80)
        nameLabel.frame = CGRect(x: imageView.right+10, y: 10+30, width: width-imageView.width-10, height: 30)
        bioLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width, height: 100)
        countContainerView.frame = CGRect(x: 10, y: bioLabel.bottom, width: width-10, height: 100)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePhoto))
        imageView.addGestureRecognizer(tap)
        
        maskImageView.frame = imageView.bounds
        imageView.mask = maskImageView
        
       
    }
    
    @objc private func didTapProfilePhoto() {
        delegate?.profileHeaderUserInfoViewDidTapProfilePicture(self)
    }

    public func configure(with viewModel: ProfileHeaderViewModel) {
        var text = ""
        var text2 = ""
        if let name = viewModel.name {
            text = name
        }
        
        if let bio = viewModel.bio {
            text2 = bio ?? "Welcome to my profile!"
        }
        
        bioLabel.text = text2
        nameLabel.text = text
        // Container
        let containerViewModel = ProfileHeaderCountViewViewModel(
            followerCount: viewModel.followerCount,
            followingCount: viewModel.followingICount,
            postsCount: viewModel.postCount,
            actioonType: viewModel.buttonType
        )
        countContainerView.configure(with: containerViewModel)
    }
    
    
}

