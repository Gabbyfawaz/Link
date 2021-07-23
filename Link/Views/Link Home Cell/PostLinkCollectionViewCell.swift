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
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 20
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(heartImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        imageView.frame = CGRect(x: 15, y: 10, width: (contentView.width-30), height: contentView.height-10)
        imageView.layer.cornerRadius = 30
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
    }

    
}

