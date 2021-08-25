//
//  PostFeedCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/31.
//

import UIKit

class PostFeedCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostFeedCollectionViewCell"
    
    
    //MARK: - Properties
    
    private let nameOfLinkView = NameofLinkCollectionView()
    private let locationOfLinkView = LocationViewContainer()
    private let inviteOfLinkView = InvitesCollectionView()
    
//    var messageArray: UIView = [nameOfLinkView,locationOfLinkView,inviteOfLinkView]
        
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        contentView.clipsToBounds = true
//        contentView.backgroundColor = .purple
        
//        contentView.insertSubview(nameOfLinkView, at: 2)
        contentView.addSubview(nameOfLinkView)
//        contentView.insertSubview(inviteOfLinkView, at: 1)
        
//        contentView.addSubview(nameOfLinkView)
//        contentView.addSubview(locationOfLinkView)
//        contentView.addSubview(inviteOfLinkView)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeUp))
        swipeUp.direction = .up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDown))
        
        swipeUp.direction = .up
        swipeDown.direction = .down
        
        contentView.addGestureRecognizer(swipeUp)
        contentView.addGestureRecognizer(swipeDown)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didSwipeUp() {
        
      
        contentView.addSubview(inviteOfLinkView)
//        insertSubview(inviteOfLinkView, at: 1)
     
        let swipeUp2 = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeUp2))
        swipeUp2.direction = .up
        contentView.addGestureRecognizer(swipeUp2)

        
    }
    
    @objc private func didSwipeUp2() {
        
        contentView.addSubview(locationOfLinkView)
//        contentView.insertSubview(locationOfLinkView, at: 2)
        
    }
    
    
    @objc private func didSwipeDown() {
        
        contentView.addSubview(inviteOfLinkView)
        let swipeDown2 = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDown2))
        swipeDown2.direction = .down
        contentView.addGestureRecognizer(swipeDown2)
        
    }
    
    @objc private func didSwipeDown2() {
        contentView.addSubview(nameOfLinkView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        nameOfLinkView.frame = contentView.bounds
        locationOfLinkView.frame = contentView.bounds
        inviteOfLinkView.frame = contentView.bounds
        
//        nameOfLinkView.bringSubviewToFront(locationOfLinkView)
//        locationOfLinkView.bringSubviewToFront(inviteOfLinkView)
//        inviteOfLinkView.sendSubviewToBack(locationOfLinkView)
    }
    
    public func configure(with viewModel: PostOfFeedCollectionViewModel) {
        
        nameOfLinkView.configure(with: viewModel)
        locationOfLinkView.configure(with: viewModel)
        inviteOfLinkView.configure(with: viewModel)
    }
    
    
}
