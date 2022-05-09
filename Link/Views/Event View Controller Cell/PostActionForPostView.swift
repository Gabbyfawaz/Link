//
//  PostActionForPostView.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/08/02.
//

import UIKit

protocol PostActionForPostViewDelegate: AnyObject {
    
    func postLinkActionsCollectionViewCellDidTapLike(_ cell: PostActionForPostView, isLiked: Bool, index: Int)
    func postLinkActionsCollectionViewCellDidTapComment(_ cell: PostActionForPostView, index: Int)
    func postLinkLikesCollectionViewCellDidTapLikeCount(_ cell: PostActionForPostView, index: Int)
}

class PostActionForPostView: UIView {


    private var index = 0
    private var isRequested = false
    weak var delegate: PostActionForPostViewDelegate?
    private var isLiked = false
    
    private let likeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "0"
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 7.5
        label.backgroundColor = .black
        label.textColor = .white
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    
    //newnew
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "1"
        label.font = UIFont.systemFont(ofSize: 15)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 7.5
        label.backgroundColor = .black
        label.textColor = .white
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()

    // new
    private let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemRed
        let image = UIImage(systemName: "suit.heart",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()

    private let commentButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        let image = UIImage(systemName: "message",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()
    

    
//        private let moreButton: UIButton = {
//            let button = UIButton()
//            button.tintColor = .white
//            let image = UIImage(systemName: "ellipsis",
//                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
//            button.setImage(image, for: .normal)
//            return button
//        }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(likeButton)
        addSubview(commentButton)
        addSubview(commentLabel)
        addSubview(likeLabel)
        
        // Gestures
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapLabel))
        likeLabel.addGestureRecognizer(tap)
        
        // Actions
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        
    }


    required init?(coder: NSCoder) {
        fatalError()
    }
    //new
    
   
    
    @objc func didTapLabel() {
        delegate?.postLinkLikesCollectionViewCellDidTapLikeCount(self, index: index)
    }

    @objc func didTapLike() {
        if self.isLiked {
            let image = UIImage(systemName: "suit.heart",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .white
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

//    @objc func didTapMore() {
//        delegate?.postLinkActionsCollectionViewCellDidTapMore(self, index: index)
//    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
     
        let size: CGFloat = 40
        likeButton.frame = CGRect(x: 0, y: (height-size), width: size, height: size)
        
        likeLabel.frame = CGRect(x: likeButton.right-10, y: 7, width: 15, height:15)
        commentButton.frame = CGRect(x: likeLabel.right+20,
                                     y: (height-size), width: size, height: size)
        commentLabel.frame = CGRect(x: commentButton.right-10, y: 7, width: 15, height: 15)
//        requestButtom.frame = CGRect(x: contentView.width-120-20, y: (contentView.height-30)/2, width: 120, height: 30)
        
//        starRatingButton.frame = CGRect(x: contentView.width-10-likeButton.right, y: (contentView.height-size), width: size, height: size)
//        starRatingLabel.frame =  CGRect(x:contentView.width-likeLabel.right-10, y: (contentView.height-size)+8, width: size-10, height: size-10)
        
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

