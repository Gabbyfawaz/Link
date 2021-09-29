//
//  PostLinkCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//


protocol PostLinkCollectionViewCellDelegate: AnyObject {
    func postLinkCollectionViewCell( _ cell: PostLinkCollectionViewCell, index: Int )
    func postCollectionViewCellDidLike(_ cell: PostLinkCollectionViewCell, index: Int)
}

import UIKit
import SDWebImage

final class PostLinkCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostLinkCollectionViewCell"

    //MARK: - Propetries
    
    private var index = 0
    private var index2 = 0
    private var postStrings = [String]()
    weak var delegate: PostLinkCollectionViewCellDelegate?
    

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()

//    private let curveView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemBackground
//        view.roundCorners(corners: [.topLeft , .topRight], radius: 10)
//        return view
//    }()

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
    

    private let rightButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.right",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        button.setImage(image, for: .normal)
        button.isHidden = false
        button.tintColor = .black
        return button
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if postStrings.count == 1 {
            rightButton.isHidden = true
        }
    
        contentView.addSubview(imageView)
        contentView.addSubview(heartImageView)
        contentView.addSubview(moreButton)
        contentView.addSubview(rightButton)

        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didSwipeRight), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        
        imageView.frame = CGRect(x: 0, y: contentView.safeAreaInsets.top, width: contentView.width, height: contentView.width+20)

        moreButton.frame = CGRect(x: contentView.width-60, y: 10, width: 50, height:50)
        rightButton.frame = CGRect(x: contentView.width-rightButton.width,
                                   y: (imageView.height-rightButton.height)/2,
                                   width: 40,
                                   height: 40)
    
        
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
        self.postStrings = viewModel.postString
        imageView.sd_setImage(with: URL(string: postStrings[index2]), completed: nil)
 
    
    }
    
    @objc func didSwipeRight() {
        
        if index2 < postStrings.count-1 {
            self.index2 += 1
            imageView.sd_setImage(with: URL(string: postStrings[index2]), completed: nil)
        } else if index2 >= postStrings.count-1 {
            index2 = 0
            imageView.sd_setImage(with: URL(string:  postStrings[index2]), completed: nil)
    
        }
        
    }
    

    
}



