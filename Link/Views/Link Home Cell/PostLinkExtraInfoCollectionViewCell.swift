//
//  PostLinkExtraInfoCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

final class PostLinkExtraInfoCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostLinkExtraInfoCollectionViewCell"
    
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.text = "Info"
        label.font = .systemFont(ofSize: 30, weight: .medium)
        return label
    }()
    
    private let label: UITextView = {
        let tf = UITextView()
//        tf.numberOfLines = 0
        tf.isUserInteractionEnabled = false
        tf.isUserInteractionEnabled = true
        tf.font = .systemFont(ofSize: 21)
        tf.textColor = .white
        tf.backgroundColor = .black
        tf.layer.masksToBounds = true
        return tf
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
        contentView.addSubview(infoLabel)
//        contentView.addSubview(moreButton)

        
//        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
//    @objc private func didTapMore() {
////        delegate?.postInfoCollectionViewCellDidTapMoreButton(self, index: index)
//    }


    override func layoutSubviews() {
        super.layoutSubviews()
//        let size = label.sizeThatFits(CGSize(width: contentView.bounds.size.width-12,
//                                             height: contentView.bounds.size.height))
        label.sizeToFit()
        infoLabel.frame = CGRect(x: 15, y: 20, width: 60, height: 50)
        label.frame = CGRect(x: infoLabel.right+20
                             , y: 20, width: contentView.width-infoLabel.width-60, height: contentView.height-20)
        label.layer.cornerRadius = 8
//        moreButton.frame = CGRect(x: contentView.width-moreButton.width-10, y: 10, width: 50, height: 50)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    func configure(with viewModel: PostLinkExtraInfoCollectionCellViewModel) {
        label.text = (viewModel.extraInfomation)
    }
}

