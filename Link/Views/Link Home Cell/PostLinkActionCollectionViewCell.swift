//
//  PostLinkActionCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

protocol PostLinkActionsCollectionViewCellDelegate: AnyObject {
    
    func postLinkActionsCollectionViewCellDidTapLike(_ cell: PostLinkActionCollectionViewCell, isLiked: Bool, index: Int)
    func postLinkActionsCollectionViewCellDidTapComment(_ cell: PostLinkActionCollectionViewCell, index: Int)
    func postLinkActionsCollectionViewCellDidTapMore(_ cell: PostLinkActionCollectionViewCell, index: Int)
    //new
    func postLinkLikesCollectionViewCellDidTapLikeCount(_ cell: PostLinkActionCollectionViewCell, index: Int)
    func posterLinkCollectionViewCellDidTapRequest(_ cell: PostLinkActionCollectionViewCell, index: Int)
}


final class PostLinkActionCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostActionCollectionViewCell"

    private var index = 0
    private var isRequested = false
    weak var delegate: PostLinkActionsCollectionViewCellDelegate?
    private var isLiked = false
    
    private let likeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 20)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    //newnew
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "1"
        label.font = UIFont.systemFont(ofSize: 20)
        label.isUserInteractionEnabled = true
        return label
    }()

    // new
    private let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemRed
        let image = UIImage(systemName: "suit.heart",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 35))
        button.setImage(image, for: .normal)
        return button
    }()

    private let commentButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemPurple
        let image = UIImage(systemName: "message",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 35))
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
    
        private let moreButton: UIButton = {
            let button = UIButton()
            button.tintColor = .label
            let image = UIImage(systemName: "ellipsis",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            button.setImage(image, for: .normal)
            return button
        }()

//    private let starRatingButton: UIButton = {
//        let button = UIButton()
//        button.tintColor = .systemYellow
//        let image = UIImage(systemName: "star.fill",
//                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 35))
//        button.setImage(image, for: .normal)
//        return button
//    }()
//
//    private let starRatingLabel: UILabel = {
//        let label = UILabel()
//        label.text = "5"
//        label.font = .systemFont(ofSize: 25)
//        return label
//    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
//        contentView.addSubview(starRatingButton)
//        contentView.addSubview(starRatingLabel)
        contentView.addSubview(moreButton)
        contentView.addSubview(commentLabel)
        contentView.addSubview(likeLabel)
//        contentView.addSubview(requestButtom)
        
        // Gestures
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapLabel))
        likeLabel.addGestureRecognizer(tap)
        
        // Actions
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
//        starRatingButton.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
//        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        
        requestButtom.addTarget(self, action: #selector(didTapRequest), for: .touchUpInside)
    }


    required init?(coder: NSCoder) {
        fatalError()
    }
    //new
    
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
           
//        }
       
       
       delegate?.posterLinkCollectionViewCellDidTapRequest(self, index: index)
   }
    
    @objc func didTapLabel() {
        delegate?.postLinkLikesCollectionViewCellDidTapLikeCount(self, index: index)
    }

    @objc func didTapLike() {
        if self.isLiked {
            let image = UIImage(systemName: "suit.heart",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .label
        }
        else {
            let image = UIImage(systemName: "suit.heart.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        }

        delegate?.postLinkActionsCollectionViewCellDidTapLike(self,
                                                          isLiked: !isLiked,
                                                          index: index)
        self.isLiked = !isLiked
    }

    @objc func didTapComment() {
        delegate?.postLinkActionsCollectionViewCellDidTapComment(self, index: index)
    }

    @objc func didTapMore() {
        delegate?.postLinkActionsCollectionViewCellDidTapMore(self, index: index)
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // newnew
        
       
        let size: CGFloat = contentView.height/1.15
        likeButton.frame = CGRect(x: 15, y: (contentView.height-size), width: size, height: size)
        
        likeLabel.frame = CGRect(x: likeButton.right+10, y: 0, width: 12, height: contentView.height)
        commentButton.frame = CGRect(x: likeLabel.right+20,
                                     y: (contentView.height-size), width: size, height: size)
        commentLabel.frame = CGRect(x: commentButton.right+10, y: 0, width: 12, height: contentView.height)
        requestButtom.frame = CGRect(x: contentView.width-120-20, y: (contentView.height-30)/2, width: 120, height: 30)
        
        moreButton.frame = CGRect(x: contentView.width-moreButton.width-60,
                                  y: (contentView.height-30)/2,
                                  width: 50,
                                  height: 30)
//        starRatingButton.frame = CGRect(x: contentView.width-10-likeButton.right, y: (contentView.height-size), width: size, height: size)
//        starRatingLabel.frame =  CGRect(x:contentView.width-likeLabel.right-10, y: (contentView.height-size)+8, width: size-10, height: size-10)
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        likeLabel.text = nil
    }

    func configure(
        with viewModel: PostLinkActionCollectionViewCellViewModel, index: Int) {
        self.index = index
        isLiked = viewModel.isLiked
        
        //new
        let users = viewModel.likers
        likeLabel.text = "\(users.count)"
        if viewModel.isLiked {
            let image = UIImage(systemName: "suit.heart.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        
        }
    }

}

