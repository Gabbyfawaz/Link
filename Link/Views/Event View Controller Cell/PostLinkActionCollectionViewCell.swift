//
//  PostLinkActionCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import Cosmos
import TinyConstraints
import EventKit
import EventKitUI

protocol PostLinkActionsCollectionViewCellDelegate: AnyObject {
    
    func postLinkActionsCollectionViewCellDidTapLike(_ cell: PostLinkActionCollectionViewCell, isLiked: Bool)
    func postLinkActionsCollectionViewCellDidTapComment(_ cell: PostLinkActionCollectionViewCell, comments: [Comment] )
    func postLinkLikesCollectionViewCellDidTapLikeCount(_ cell: PostLinkActionCollectionViewCell, likers: [String])
    func postLinkLikesCollectionViewCellDidTapBell(_ cell: PostLinkActionCollectionViewCell, date: Date, linkName: String)
//    func postLinkCollectionViewCellDidTapComments(_ cell: PostLinkActionCollectionViewCell, comments: [Comment] )
}


final class PostLinkActionCollectionViewCell: UICollectionViewCell {
    
 
    
    static let identifier = "PostActionCollectionViewCell"

    private var index = 0
    private var isRequested = false
    private var likers = [String]()
    weak var delegate: PostLinkActionsCollectionViewCellDelegate?
    private var isLiked = false
    private var observer: NSObjectProtocol?
    private var updateCounterObserver: NSObjectProtocol?
    private var likeCounts: Int?
    private var commentModel = [Comment]()
    private var username: String?
    private var linkId: String?
    private var date: Date?
    private var linkName: String?
    private var horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    private var horizontalStackView2: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 2
        return stack
    }()
    
    
    private let likeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.text = "0 likes"
        label.isUserInteractionEnabled = true
        return label
    }()
    
    //newnew
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private var priceStackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 2
        return stack
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .label
        label.textAlignment = .left
        label.text = "Free"
        return label
    }()
    
    private let priceImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "tag.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8))
        iv.tintColor = .label
        return iv
    }()
    

    private let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemRed
        let image = UIImage(systemName: "heart",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        button.tintColor = .systemRed
        return button
    }()

    private let commentButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "message",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let bellButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemOrange
        let image = UIImage(systemName: "bell.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()
    
//    private let viewCommentsLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .left
//        label.textColor = .darkGray
//        label.font = .systemFont(ofSize: 15, weight: .light)
//        label.layer.masksToBounds = true
//        label.layer.cornerRadius = 8
//        label.isUserInteractionEnabled = true
//        return label
//    }()
    
    lazy var cosmosView: CosmosView = {
        let view = CosmosView()
        view.settings.starSize = 20
        view.settings.updateOnTouch = true
        view.rating = 3
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
        contentView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(likeButton)
        horizontalStackView.addArrangedSubview(commentButton)
        horizontalStackView.addArrangedSubview(bellButton)
        contentView.addSubview(horizontalStackView2)
        horizontalStackView2.addArrangedSubview(likeLabel)
        horizontalStackView2.addArrangedSubview(commentLabel)
//        contentView.addSubview(viewCommentsLabel)
        contentView.addSubview(priceStackView)
        priceStackView.addArrangedSubview(priceImageView)
        priceStackView.addArrangedSubview(priceLabel)
        contentView.addSubview(cosmosView)
//        contentView.addSubview(starView)
        contentView.addSubview(daysLeftLabel)
       
      
        didTouchCosmos()
        
        // Gestures
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapLabel))
        likeLabel.addGestureRecognizer(tap)
        
        
//        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapViewAllComments))
//
//        viewCommentsLabel.addGestureRecognizer(tap2)
        // Actions
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        bellButton.addTarget(self, action: #selector(didTapBell), for: .touchUpInside)
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        observer = NotificationCenter.default.addObserver(
                    forName: .didDoubleTapImage,
                    object: nil,
                    queue: .main
                ) {  _ in
                    let image = UIImage(systemName: "heart.fill",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
                    let hasLiked = self.likers.contains(username)
             
                    
                    if (self.likeButton.imageView?.image == UIImage(systemName: "heart",
                                                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))) {
                       
                        self.likeButton.setImage(image, for: .normal)
                        self.likers.append(username)
                        self.likeLabel.text = "\(self.likers.count) likes"
                      
                       
                     let isLiked = self.isLiked
                        self.delegate?.postLinkActionsCollectionViewCellDidTapLike(self,
                                                                          isLiked: !isLiked)
                        self.isLiked = !(isLiked)
                    }
                   
                }
        
        
//        updateCounterObserver = NotificationCenter.default.addObserver(
//            forName: .updateLikeCount,
//            object: nil,
//            queue: .main,
//            using: { [weak self] noti in
//                let userInfo = noti.userInfo
//                let value = userInfo?.first?.value
//                guard let likers = value as? [String] else {
//                    return
//                }
//                print("the likers are: \(likers)")
//                self?.likeLabel.text = "\(likers.count) likes"
//                self?.likers = likers
//            })

    }


    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
//    @objc func didTapViewAllComments() {
//        delegate?.postLinkCollectionViewCellDidTapComments(self, comments: commentModel)
//    }
    
    
    
    @objc func didTapLabel() {
        delegate?.postLinkLikesCollectionViewCellDidTapLikeCount(self, likers: likers )
    }

    @objc func didTapLike() {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        if self.isLiked {
            let image = UIImage(systemName: "heart",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            likeButton.setImage(image, for: .normal)

            if likers.contains(username) {
                if let index = likers.firstIndex(of: username) {
                    likers.remove(at: index)
                }
                likeLabel.text = "\(likers.count) likes"

            }
           
        }
        else {
            let image = UIImage(systemName: "heart.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            
            likeButton.setImage(image, for: .normal)
            if !likers.contains(username) {
                self.likers.append(username)
                likeLabel.text = "\(likers.count) likes"
            }
          
//            self.likeCounts = newCount
            
        
        }

        delegate?.postLinkActionsCollectionViewCellDidTapLike(self,
                                                          isLiked: !isLiked)
        self.isLiked = !isLiked
       
    }

    @objc func didTapComment() {
        delegate?.postLinkActionsCollectionViewCellDidTapComment(self, comments: commentModel)
    }

    @objc func didTapBell() {
        /// give a reminder
        
        guard let date = date, let linkName = linkName else {
            return
        }

        delegate?.postLinkLikesCollectionViewCellDidTapBell(self, date: date, linkName: linkName)
//
    }
    
    
   
    
    private func didCalculateRate(rating: [Double]) {
        var totalRating = 0.0
        let count = rating.count
        

        
        rating.forEach { rate in
            totalRating += rate
        }
        if count > 0 {
            let finalRatingValue = totalRating/Double(rating.count)
            self.cosmosView.rating = (round(finalRatingValue))
        } else {
            self.cosmosView.rating = 0.0
        }
       
       
    }

    
    
//    private func didCalculateRate(rating: [Rating]) {
//        var totalRating = 0.0
//        let count = rating.count
//
//        rating.forEach { rate in
//            let rateValue = rate
//            totalRating += rateValue
//        }
//        if count > 0 {
//            let finalRatingValue = totalRating/Double(rating.count)
//            self.cosmosView.rating = Double(finalRatingValue)
//        } else {
//            self.cosmosView.rating = 0.0
//        }
//
//
//    }
    

    private func didTouchCosmos() {
        
            (cosmosView.didTouchCosmos) = { rating in
                
                guard let username = self.username, let linkId = self.linkId else {
                    return
                }

                self.cosmosView.rating = rating
                DatabaseManager.shared.UpdateEventRating(eventUser: username, linkid: linkId, rating: rating) { success in
                    
                    if success {
                        print("Updated rating")
                        self.cosmosView.isUserInteractionEnabled = false
                    }
                }
            }
    
     
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        cosmosView.leftToSuperview(nil, offset: 20, relation: ConstraintRelation.equal, priority: LayoutPriority.defaultHigh, isActive: true, usingSafeArea: false)
//
//        starView.frame = CGRect(x: 20, y: 0, width: 100, height: 20)
        daysLeftLabel.frame = CGRect(x: 20,
                                     y: cosmosView.bottom+10,
                                     width: contentView.width/4.5,
                                     height: 20)
        
        priceStackView.frame =  CGRect(x: 20,
                                          y: daysLeftLabel.bottom+10,
                                          width: 100,
                                          height: 20)
        
        let paddingWidth = width/3

        horizontalStackView.frame = CGRect(x: paddingWidth*2-5,
                                         y: 0,
                                         width: 120,
                                         height: 30)

//        horizontalStackView2.sizeToFit()
        
        horizontalStackView2.frame = CGRect(x: paddingWidth*2-10,
                                            y: horizontalStackView.bottom+10,
                                            width: 130,
                                            height: 10)
    
       
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        likeLabel.text = nil
        commentLabel.text = nil
    }

    func configure(
        with viewModel: PostLinkActionCollectionViewCellViewModel, index: Int) {
        
       
        didCalculateRate(rating: viewModel.rating)
        guard let username = UserDefaults.standard.string(forKey: "username") else {
                return }
            
            if viewModel.userWhoRated.contains(username) {
                cosmosView.isUserInteractionEnabled = false
                print("the user has already rated event")
            }
        self.index = index
        isLiked = viewModel.isLiked
        self.date = Date(timeIntervalSince1970: viewModel.dateOfLink)
            self.linkName = viewModel.linkName
        self.commentModel = viewModel.comments
        //new
        self.username = viewModel.username
        self.linkId = viewModel.linkId
        let users = viewModel.likers
        likeLabel.text = "\(users.count) likes"
//            likeLabel.text = "10 likes"
            self.likeCounts = users.count
            commentLabel.text = "\(viewModel.comments.count) comments"
//            commentLabel.text = "2 comments"
        if viewModel.isLiked {
            let image = UIImage(systemName: "heart.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 44))
            likeButton.setImage(image, for: .normal)
            
    

        }
//        viewCommentsLabel.text = "View Comments"
        
        
        let dateRangeStart = Date()
        let dateRangeEnd = Date(timeIntervalSince1970: viewModel.dateOfLink)
        print("The date is:\(dateRangeEnd)")
        let components = Calendar.current.dateComponents([.day], from: dateRangeStart, to: dateRangeEnd)
        let days = components.day ?? 0
            print("The number of days is: \(days)")
            if days > 0 {
//                daysLeftLabel.text = "\(days) Days Left"
                daysLeftLabel.text = "\(days+1) Days Left"
            } else  if days <= 0 {
                daysLeftLabel.text = "Complete"
            }
            
           
            
            
            
    }

}




