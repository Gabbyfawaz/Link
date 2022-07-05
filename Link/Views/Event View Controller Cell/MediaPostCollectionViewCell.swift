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
    private var rating =  [Double]()
    
    

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
    
    private var  stackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 5
//        stack.backgroundColor = UIColor(white: 0.7, alpha: 0.6)
        stack.backgroundColor = .systemBackground
        stack.layer.cornerRadius = 5
        return stack
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let rateButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemBackground
        let image = UIImage(systemName: "star.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 15))
        button.setImage(image, for: .normal)
        button.tintColor = .systemOrange
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
       contentView.addSubview(stackView)
       stackView.addArrangedSubview(rateButton)
       stackView.addArrangedSubview(label)


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
    
    
    private func didCalculateRate(rating: [Double]) {
        var totalRating = 0.0
        let count = rating.count
        
        
        rating.forEach { rate in
            totalRating += rate
        }
        if count > 0 {
            let finalRatingValue = totalRating/Double(rating.count)
            label.text = "\(round(finalRatingValue))"
        } else {
            label.text = "0.0"
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
        
        stackView.frame = CGRect(x: 5,
                                  y: 5,
                                  width: 60,
                                  height: 30)
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
        didCalculateRate(rating: viewModel.rating)
        self.postStrings = viewModel.postString
//        self.rating = viewModel.rating
        imageView.sd_setImage(with: URL(string: postStrings[index]), completed: nil)
        if !(postStrings.count == 1) {
            rightButton.isHidden = false
            leftButton.isHidden = false
        }
    
    }
    

    

    
}



