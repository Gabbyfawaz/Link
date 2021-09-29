//
//  PostInfoCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import SDWebImage

protocol PostInfoCollectionViewCellDelegate: AnyObject {
    func posterCollectionViewCellDidTapUsername(_ cell: PostInfoCollectionViewCell, index: Int)
}
  

final class PostInfoCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostInfoCollectionViewCell"
    private var index = 0
    private var cellHeight: CGFloat = 50
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
     

    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    


    @objc func didTapInfo() {
        delegate?.posterCollectionViewCellDidTapUsername(self, index: index)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = label.sizeThatFits(CGSize(width: contentView.bounds.size.width-12,
                                             height: contentView.bounds.size.height))

        label.frame = CGRect(x: 15
                             , y: 20, width: size.width-15, height: size.height)
        
        
        cellHeight = label.height+10
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }


    func configure(with viewModel: PostLinkExtraInfoCollectionCellViewModel, index: Int) {
        self.index = index
        label.text = "\(viewModel.username): \(viewModel.extraInfomation ?? "")"
    
    }
}


