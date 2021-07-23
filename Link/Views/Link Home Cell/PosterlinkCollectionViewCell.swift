//
//  PosterlinkCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import FirebaseAuth


protocol PosterLinkCollectionViewCellDelegate: AnyObject {
    func posterLinkCollectionViewCellDidTapRequest(_ cell: PosterlinkCollectionViewCell, index: Int)
    func posterLinkCollectionViewCellDidTapRepost(_ cell: PosterlinkCollectionViewCell, index: Int)
    func posterLinkCollectionViewCellDidTapImageView(_ cell: PosterlinkCollectionViewCell, index: Int)
}

final class PosterlinkCollectionViewCell: UICollectionViewCell {
    static let identifier = "PosterlinkCollectionViewCell"

    //MARK: -  Properties
    
    private var index = 0

    private var isRequested = false
    
    weak var delegate: PosterLinkCollectionViewCellDelegate?
    
//    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.masksToBounds = true
//        imageView.isUserInteractionEnabled = true
//        imageView.backgroundColor = .systemBackground
////        imageView.image?.withTintColor(.white)
//        return imageView
//    }()

    private let typeOfLink: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "ellipsis",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()

    lazy private var requestButtom: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Request", for: .normal)
//        if  Auth.auth().currentUser?.email == UserDefaults.standard.string(forKey: "email") {
//            button.setTitle("Repost", for: .normal)
//            button.backgroundColor = .systemBlue
//            button.addTarget(self, action: #selector(didTapRepost), for: .touchUpInside)
//            }
        button.setTitleColor(.white, for: .normal)
//        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.layer.cornerRadius = 8
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
//        contentView.addSubview(imageView)
        contentView.addSubview(typeOfLink)
        contentView.addSubview(moreButton)
        contentView.addSubview(requestButtom)
        
        requestButtom.addTarget(self, action: #selector(didTapRequest), for: .touchUpInside)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
//        imageView.addGestureRecognizer(tap)
    
    }
    
    //MARK: - Actions
    
    @objc private func didTapProfileImage() {
        
        delegate?.posterLinkCollectionViewCellDidTapImageView(self, index: index)
    }
    
     @objc private func didTapRequest() {
        
        isRequested = !isRequested
        
 //        if  Auth.auth().currentUser?.email == UserDefaults.standard.string(forKey: "email") {
 //            requestButtom.setTitle("Repost", for: .normal)
 //            requestButtom.backgroundColor = .systemBlue
 //            requestButtom.addTarget(self, action: #selector(didTapRepost), for: .touchUpInside)
 //        } else {
            if isRequested {
                requestButtom.setTitle("Requesting", for: .normal)
                requestButtom.backgroundColor = .darkGray
                requestButtom.layer.borderColor = UIColor.secondarySystemBackground.cgColor
 //                requestButtom.layer.borderWidth = 3
                print(isRequested)
            } else {
                requestButtom.setTitle("Request", for: .normal)
                requestButtom.backgroundColor = .black
                print(isRequested)
            }
        
        
        delegate?.posterLinkCollectionViewCellDidTapRequest(self, index: index)
        
    }
    
    @objc private func didTapRepost() {
        delegate?.posterLinkCollectionViewCellDidTapRepost(self, index: index)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imagePadding: CGFloat = 4
        let imageSize: CGFloat = contentView.height - (imagePadding * 4)
//        imageView.frame = CGRect(x: 15, y: imagePadding+4, width: imageSize, height:imageSize)
//        imageView.layer.cornerRadius = imageSize/2

        typeOfLink.sizeToFit()
        typeOfLink.frame = CGRect(
            x: 20,
            y: 10,
            width: typeOfLink.width,
            height: contentView.height
        )

        requestButtom.frame = CGRect(x: contentView.width-120-20, y: contentView.height-45, width: 120, height: 30)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ConfigureUI
    func configure(with viewModel: PosterLinkCollectionViewCellViewModel, index: Int) {
        
        // add index parameter
        self.index = index
        typeOfLink.text = viewModel.linkType
//        imageView.sd_setImage(with: viewModel.profilePictureURL, completed: nil)
//        imageView.image?.sd_colors(with: [UIColor(white: 1, alpha: 1)])
            }
    
}

