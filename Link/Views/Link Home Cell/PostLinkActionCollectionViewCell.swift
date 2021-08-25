//
//  PostLinkActionCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import Cosmos
import TinyConstraints

protocol PostLinkActionsCollectionViewCellDelegate: AnyObject {
    
    func postLinkActionsCollectionViewCellDidTapLike(_ cell: PostLinkActionCollectionViewCell, isLiked: Bool, index: Int)
    func postLinkActionsCollectionViewCellDidTapComment(_ cell: PostLinkActionCollectionViewCell, index: Int)
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
        label.font = UIFont.systemFont(ofSize: 15)
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
    
    private let commentsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        return label
    }()
    
    lazy var cosmosView: CosmosView = {
        let view = CosmosView()
        view.settings.starSize = 20
        view.settings.updateOnTouch = true
        return view
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
        contentView.addSubview(commentLabel)
        contentView.addSubview(likeLabel)
        contentView.addSubview(commentsLabel)
        contentView.addSubview(cosmosView)
//        cosmosView.leftToSuperview()
        
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
    
    
    
    @objc func didTapLabel() {
        delegate?.postLinkLikesCollectionViewCellDidTapLikeCount(self, index: index)
    }

    @objc func didTapLike() {
        if self.isLiked {
            let image = UIImage(systemName: "suit.heart",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        }
        else {
            let image = UIImage(systemName: "suit.heart.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
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


    override func layoutSubviews() {
        super.layoutSubviews()
        
        // newnew
        
       
        likeButton.frame = CGRect(x: contentView.width-140, y: 0, width: 40, height: 40)
        
        likeLabel.frame = CGRect(x: likeButton.right-10, y: 5, width: 15, height:15)
        commentButton.frame = CGRect(x: likeLabel.right+20,
                                     y: 0, width: 40, height: 40)
        commentLabel.frame = CGRect(x: commentButton.right-10, y: 5, width: 15, height: 15)
        
        
        commentsLabel.sizeToFit()
        
        commentsLabel.frame = CGRect(x: likeButton.left,
                                     y: 40+7,
                                     width: commentsLabel.width,
                                     height: commentsLabel.height)
    
        cosmosView.frame = CGRect(x: 15, y: 10, width: 10, height: 40)
        
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
        commentLabel.text = "1"
        commentsLabel.text = "View Comments"
    }

}

