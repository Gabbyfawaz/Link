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
    func postLinkLikesCollectionViewCellDidTapLikeViewComments(_ cell: PostLinkActionCollectionViewCell, index: Int)
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
        let image = UIImage(systemName: "message",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let viewCommentsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var cosmosView: CosmosView = {
        let view = CosmosView()
        view.settings.starSize = 20
        view.settings.updateOnTouch = true
        return view
    }()
    

    private var daysLeftLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .red
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.text = "1 Day left"
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(commentLabel)
        contentView.addSubview(likeLabel)
        contentView.addSubview(viewCommentsLabel)
        contentView.addSubview(cosmosView)
        contentView.addSubview(daysLeftLabel)

       
        
        // Gestures
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapLabel))
        likeLabel.addGestureRecognizer(tap)
        
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapViewAllComments))
        
        viewCommentsLabel.addGestureRecognizer(tap2)
        // Actions
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)

    }


    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    @objc func didTapViewAllComments() {
        delegate?.postLinkLikesCollectionViewCellDidTapLikeViewComments(self, index: index)
        
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
        
        
        viewCommentsLabel.sizeToFit()
        
        viewCommentsLabel.frame = CGRect(x: likeButton.left,
                                     y: 40+7,
                                     width: viewCommentsLabel.width,
                                     height: viewCommentsLabel.height)
    
        cosmosView.leftToSuperview(nil, offset: 20, relation: ConstraintRelation.equal, priority: LayoutPriority.defaultHigh, isActive: true, usingSafeArea: false)
        
        daysLeftLabel.frame = CGRect(x: 20,
                                     y: cosmosView.bottom+10,
                                     width: 90,
                                     height: 20)
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
        commentLabel.text = "\(viewModel.comments)"
        if viewModel.isLiked {
            let image = UIImage(systemName: "suit.heart.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .systemRed
        
        }
        viewCommentsLabel.text = "View Comments"
        
        
        let dateRangeStart = Date()
        guard let dateRangeEnd = DateFormatter.formatter.date(from: viewModel.dateOfLink) else {return}
        print("The date is:\(dateRangeEnd)")
        let components = Calendar.current.dateComponents([.year, .weekOfYear, .month, .day], from: dateRangeStart, to: dateRangeEnd)

//        let months = components.month ?? 0
//        let weeks = components.weekOfYear ?? 0
        let year = components.year ?? 0
        let months = components.month ?? 0
        let weeks = components.weekOfYear ?? 0
        let days = components.day ?? 0
        let daysInWeeks = weeks*7
        let totalDays = days + daysInWeeks
        
        if year >= 1 {
            daysLeftLabel.text = "\(year) Year Left"
        } else if months >= 1 {
            daysLeftLabel.text = "\(months) Months Left"
        } else if totalDays >= 0 {
            daysLeftLabel.text = "\(totalDays) Days Left"
        } else {
            daysLeftLabel.text = "Complete"
        }
        
        
        
    }

}

