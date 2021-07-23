//
//  PostInfoCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import SDWebImage

protocol PostInfoCollectionViewCellDelegate: AnyObject {
    func postInfoCollectionViewCellDidTapInfo(_ cell: PostInfoCollectionViewCell)
//    func postInfoCollectionViewCellDidTapMoreButton(_ cell: PostInfoCollectionViewCell, index: Int)
}

final class PostInfoCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostInfoCollectionViewCell"
    
    private var index = 0
    weak var delegate: PostInfoCollectionViewCellDelegate?
    private var profileURL: URL?

//    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.masksToBounds = true
//        imageView.isUserInteractionEnabled = true
//        imageView.backgroundColor = .black
////        imageView.image?.withTintColor(.white)
//        return imageView
//    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
//    private let moreButton: UIButton = {
//        let button = UIButton()
//        button.tintColor = .label
//        let image = UIImage(systemName: "ellipsis",
//                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
//        button.setImage(image, for: .normal)
//        return button
//    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
//        contentView.addSubview(imageView)
//        contentView.addSubview(moreButton)
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapInfo))
        label.addGestureRecognizer(tap)
        
//        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
//    @objc private func didTapMore() {
////        delegate?.postInfoCollectionViewCellDidTapMoreButton(self, index: index)
//    }

    @objc func didTapInfo() {
        delegate?.postInfoCollectionViewCellDidTapInfo(self)
        }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = label.sizeThatFits(CGSize(width: contentView.bounds.size.width-12,
                                             height: contentView.bounds.size.height))
//
//        let imagePadding: CGFloat = 4
//        let imageSize: CGFloat = contentView.height - (imagePadding * 5)
//        imageView.frame = CGRect(x: 15, y: imagePadding+4, width: imageSize, height:imageSize)
//        imageView.layer.cornerRadius = imageSize/2
//
//        label.sizeToFit()
//        label.frame = CGRect(
//            x: imageView.right+20,
//            y: 0,
//            width: label.width,
//            height: contentView.height
//        )
//
        
        label.frame = CGRect(x: 15
                             , y: 20, width: size.width, height: size.height)
//        moreButton.frame = CGRect(x: contentView.width-moreButton.width-10, y: 10, width: 50, height: 50)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    func configure(with viewModel: PostInfoCollectionViewCellViewModel, index: Int) {
        self.index = index
        label.text = "\(viewModel.username): \(viewModel.info ?? "")"
        
//        StorageManager.shared.profilePictureURL(for: viewModel.username) { [weak self] url in
//            guard  let profileURL = url else {
//                return
//
//            }
//            self?.profileURL = profileURL
//        }
//
//        DispatchQueue.main.async {
//            self.imageView.sd_setImage(with: self.profileURL, completed: nil)
//        }
    }
}


