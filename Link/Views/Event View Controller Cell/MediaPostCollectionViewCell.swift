//
//  PostLinkCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//


protocol MediaPostCollectionViewCellDelegate: AnyObject {
    func postLinkCollectionViewCell( _ cell: MediaPostCollectionViewCell, index: Int )
    func postCollectionViewCellDidLike(_ cell: MediaPostCollectionViewCell, index: Int)
}

import UIKit
import SDWebImage

final class MediaPostCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostLinkCollectionViewCell"

    //MARK: - Propetries
    
    private var index = 0
    private var postStrings = [String]()
    weak var delegate: MediaPostCollectionViewCellDelegate?
    

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()


    private let heartImageView: UIImageView = {
        let image = UIImage(systemName: "heart.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemBackground
        imageView.isHidden = true
        imageView.alpha = 0
        return imageView
    }()

    private let moreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemBackground
        let image = UIImage(systemName: "ellipsis",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        button.setImage(image, for: .normal)
        return button
    }()
    

    private let rightButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.right.circle.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        button.setImage(image, for: .normal)
        button.isHidden = true
        button.tintColor = .secondarySystemBackground
        return button
    }()
    
    private let leftButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.left.circle.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        button.setImage(image, for: .normal)
        button.isHidden = true
        button.tintColor = .secondarySystemBackground
        return button
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        
      
    
        addSubviews()
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)

        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didSwipeRight), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(didSwipeLeft), for: .touchUpInside)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(didSwipeLeft))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action:  #selector(didSwipeRight))
        swipeRight.direction = .right
        swipeLeft.direction = .left
        imageView.addGestureRecognizer(swipeLeft)
        imageView.addGestureRecognizer(swipeRight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Main Actions
    
   private func addSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(heartImageView)
        contentView.addSubview(moreButton)
        contentView.addSubview(rightButton)
       contentView.addSubview(leftButton)

    }
    
   
    //MARK: - Actions from Buttons
    
    @objc func didTapMore() {
        delegate?.postLinkCollectionViewCell(self, index: index)
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

        delegate?.postCollectionViewCellDidLike(self, index: index)
        NotificationCenter.default.post(name: .didDoubleTapImage,
                                        object: nil)
        
    }
    
    @objc func didSwipeRight() {
        
        let limit = postStrings.count-1
        
        if index < limit {
            self.index += 1
        imageView.sd_setImage(with: URL(string: postStrings[index]), completed: nil)
        } else if index >= limit {
            index = 0
            imageView.sd_setImage(with: URL(string: postStrings[index]), completed: nil)
        }
            
    }
    
    @objc func didSwipeLeft() {
        let limit = postStrings.count-1
        
        if index <= postStrings.count-1 && index > 0 {
            self.index -= 1
        imageView.sd_setImage(with: URL(string: postStrings[index]), completed: nil)
        } else if index <= 0  {
            index = limit
            imageView.sd_setImage(with: URL(string: postStrings[index]), completed: nil)
        }
    }
    
    
    
    //MARK: - Layout of Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()

        
        imageView.frame = CGRect(x: 0, y: contentView.safeAreaInsets.top, width: contentView.width, height: contentView.width+20)

        moreButton.frame = CGRect(x: contentView.width-60, y: 10, width: 50, height:50)
        
        rightButton.frame = CGRect(x: contentView.width-40-5,
                                   y: (contentView.width+20-40)/2,
                                   width: 40,
                                   height: 40)
        leftButton.frame = CGRect(x: 5,
                                   y: (contentView.width+20-40)/2,
                                   width: 40,
                                   height: 40)
    
        
        let size: CGFloat = contentView.width/8
        heartImageView.frame = CGRect(
            x: (contentView.width-size+10)/2,
            y: (contentView.height-size)/2,
            width: size+10,
            height: size)
    }

    //MARK: - Prepare Resuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    //MARK: - ConfigureUI
    
    func configure(with viewModel: MediaPostCollectionViewCellViewModel) {
//         remember to add index parameter
//        self.index = index
        self.postStrings = viewModel.postString
        imageView.sd_setImage(with: URL(string: postStrings[index]), completed: nil)
        if !(postStrings.count == 1) {
            rightButton.isHidden = false
            leftButton.isHidden = false
        }
    
    }
    

    

    
}



