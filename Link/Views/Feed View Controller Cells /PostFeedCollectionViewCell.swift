//
//  PostFeedCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/31.
//

import UIKit
import CoreAudio


class PostFeedCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PostFeedCollectionViewCell"
    
    
    //MARK: - Properties
    
    public let nameOfLinkView = NameofLinkCollectionView()
    public let inviteOfLinkView = InvitesCollectionView()
    public let locationOfLinkView = LocationViewContainer()
    private var viewArray = [UIView]()
    private var observer: NSObjectProtocol?
    private var index = 0
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       viewArray = [nameOfLinkView, inviteOfLinkView, locationOfLinkView]
        
        addSubview(locationOfLinkView)
        addSubview(inviteOfLinkView)
        addSubview(nameOfLinkView)

        swipeViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didSwipeLeft() {
        let limit = viewArray.count-1
        
        if index < limit {
            print("the index = \(index)")
            self.index += 1
            checkView()
        } else if index >= limit {
            print("the index = \(index)")
            index = 0
            checkView()
        }
    
        
        
    }
    
    @objc private func didSwipeRight() {
        let limit = viewArray.count-1
        if index <= limit && index > 0 {
            index -= 1
            checkView()
        } else if index <= 0 {
            index = limit
            checkView()
        }
    }
    
    


    private func swipeViews() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        
        swipeRight.direction = .right
        swipeLeft.direction = .left
        
        let view = self.viewArray[index]
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
        
    }
    
    
    private func checkView() {
        swipeViews()
        
        let view = self.viewArray[index]
        
        if view == nameOfLinkView {
            nameOfLinkView.isHidden = false
            inviteOfLinkView.isHidden = true
            locationOfLinkView.isHidden = true
        }  else if view == inviteOfLinkView {
            nameOfLinkView.isHidden = true
            inviteOfLinkView.isHidden = false
            locationOfLinkView.isHidden = true
        } else if view == locationOfLinkView {
            nameOfLinkView.isHidden = true
            inviteOfLinkView.isHidden = true
            locationOfLinkView.isHidden = false
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        nameOfLinkView.frame = bounds
        inviteOfLinkView.frame = bounds
        locationOfLinkView.frame = bounds

    }
    
    
    public func configure(with viewModel: PostOfFeedCollectionViewModel, index: Int) {
        

        nameOfLinkView.configure(with: viewModel)
        locationOfLinkView.configure(with: viewModel)
        inviteOfLinkView.configure(with: viewModel, index: index)
                
    }
    
}
