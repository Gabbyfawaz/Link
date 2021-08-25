//
//  PostLinkCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

final class PostLinkCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostLinkCollectionViewCell"

    //MARK: - Propetries
    
    private var index = 0
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
//        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()


    private let curveImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
//        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .systemBackground
        return imageView
    }()
    
    private var maskImageView: UIImageView = {
        let maskImageView = UIImageView()
        maskImageView.contentMode = .scaleAspectFit
        maskImageView.image = #imageLiteral(resourceName: "mask")
        return maskImageView
    }()
    private let heartImageView: UIImageView = {
        let image = UIImage(systemName: "suit.heart.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 50))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
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
    
    private let actionsView = PostActionForPostView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        contentView.clipsToBounds = true
//        contentView.layer.cornerRadius = 20
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(heartImageView)
        contentView.insertSubview(imageView, at: 0)
        contentView.insertSubview(curveImageView, at: 1)
//        contentView.addSubview(iconImageView)
        contentView.addSubview(moreButton)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapMore() {
//        delegate?.postLinkActionsCollectionViewCellDidTapMore(self, index: index)
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

//        delegate?.postCollectionViewCellDidLike(self, index: index)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        imageView.frame = contentView.bounds
        imageView.frame = CGRect(x: 0, y: -5, width: (contentView.width), height: contentView.height)
        curveImageView.frame = CGRect(x: 0, y: imageView.bottom-20, width: (contentView.width), height: 100)
        curveImageView.layer.cornerRadius = 25
        curveImageView.layer.masksToBounds = true
        iconImageView.frame = CGRect(x: 15, y: 15, width: 80, height: 80)
        moreButton.frame = CGRect(x: contentView.width-60, y: 10, width: 50, height:50)
        
        iconImageView.mask = maskImageView
        maskImageView.frame = iconImageView.bounds
        
//        imageView.layer.cornerRadius = 30
        let size: CGFloat = contentView.width/5
        heartImageView.frame = CGRect(
            x: (contentView.width-size)/2,
            y: (contentView.height-size)/2,
            width: size,
            height: size)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func configure(with viewModel: PostLinkCollectionViewCellViewModel, index: Int) {
//         remember to add index parameter
        self.index = index
        imageView.sd_setImage(with: viewModel.postUrl, completed: nil)
        
        
        StorageManager.shared.profilePictureURL(for: viewModel.user) { (url) in
            guard let profileUrl = url else {return}
            self.iconImageView.sd_setImage(with: profileUrl, completed: nil)
        }
    }

    
}

