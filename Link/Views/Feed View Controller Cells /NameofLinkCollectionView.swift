//
//  NameofLinkCollectionView.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/31.
//

import UIKit

import UIKit
import FirebaseAuth


protocol NameofLinkCollectionViewDelegate: AnyObject {
    func nameofLinkCollectionViewDidTapImage(_view: NameofLinkCollectionView, linkId: String, username: String)
    func nameofLinkCollectionViewDidDoubleTapImage(_view: NameofLinkCollectionView, linkId: String, username: String)
}
final class NameofLinkCollectionView: UIView {

    //MARK: -  Properties
    
    weak var delegate: NameofLinkCollectionViewDelegate?
    private var isLiked = false
    private var linkId: String?
    private var username: String?
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .systemBackground
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .systemBackground
        return imageView
    }()

    private let typeOfLink: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 27, weight: .bold)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        return label
    }()
    
    private let heartImageView: UIImageView = {
        let image = UIImage(systemName: "heart.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .secondarySystemBackground
        imageView.isHidden = true
        imageView.alpha = 0
        return imageView
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        let image = UIImage(systemName: "ellipsis",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = .systemBackground
        layer.cornerRadius = 20
        addSubview(imageView)
        addSubview(typeOfLink)
        addSubview(heartImageView)
        insertSubview(backgroundImageView, at: 0)
//        addSubview(moreButton)
//        tapGesture.delegate = self
//        doubleTapGesture.delegate = self
        
       let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundImage))
        backgroundImageView.addGestureRecognizer(tapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        doubleTapGesture.numberOfTapsRequired = 2
        backgroundImageView.addGestureRecognizer(doubleTapGesture)
        tapGesture.require(toFail: doubleTapGesture)
        
        
       
    }
    
    //MARK: - Actions
    
    @objc private func didTapBackgroundImage() {
    
        print("Pleaase head on over to the user's page")
        
        guard let linkId = linkId, let username = username else {return}
        delegate?.nameofLinkCollectionViewDidTapImage(_view: self, linkId: linkId, username: username)
        
    }
    
    @objc func didDoubleTapToLike() {
        heartImageView.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.heartImageView.alpha = 1
        } completion: { done in
            if done {
                UIView.animate(withDuration: 0.4) {
                    self.heartImageView.alpha = 0
                } completion: { done in
                    if done {
                        self.heartImageView.isHidden = true
                    }
                }
            }
        }

        guard let linkId = linkId, let username = username else {return}
        delegate?.nameofLinkCollectionViewDidDoubleTapImage(_view: self, linkId: linkId, username: username)
        
    }
    

    
    
    
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundImageView.frame = bounds
        
//        let imagePadding: CGFloat = 4
        let imageSize: CGFloat = height/4
        imageView.frame = CGRect(x: 15,
                                 y: height-imageSize-15,
                                 width: imageSize,
                                 height:imageSize)
        imageView.layer.cornerRadius = imageSize/2

        typeOfLink.sizeToFit()
        typeOfLink.frame = CGRect(
            x: imageView.right+10,
            y: height-imageSize,
            width: typeOfLink.width,
            height: typeOfLink.height
        )
        
        heartImageView.frame = CGRect(x: (width-heartImageView.width)/2, y: (height-heartImageView.height)/2, width: 60, height: 50)
        
//        likeButton.frame = CGRect(x: width-likeButton.width-10, y: height-imageSize, width: 40, height: 40)
        
//        moreButton.frame = CGRect(x: width-moreButton.width-10,
//                                     y: height-imageSize,
//                                     width: 40,
//                                     height: 20)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: - ConfigureUI
    func configure(with viewModel: PostOfFeedCollectionViewModel) {
        
        // add index parameter
        typeOfLink.text = viewModel.linkType
        self.linkId = viewModel.linkId
        self.username = viewModel.username
        guard let image = viewModel.mainImage?[0] else {
            return
        }
        
        DispatchQueue.main.async {
            self.imageView.sd_setImage(with: viewModel.linkTypeImage, completed: nil)
            self.backgroundImageView.sd_setImage(with: URL(string: image), completed: nil)
        }
            
    }

    
   
    
}


