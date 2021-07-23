//
//  PostLinkDateCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//


import UIKit


final class PostLinkDateCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostLinkDateCollectionViewCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "calendar")
        iv.tintColor = .black
        return iv
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.backgroundColor = .systemBackground
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
        contentView.addSubview(imageView)
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
//        let size = label.sizeThatFits(CGSize(width: contentView.bounds.size.width,
//                                             height: contentView.bounds.size.height))
        imageView.frame = CGRect(x: 15, y: 0, width: 50, height: 40)
        label.frame = CGRect(x: imageView.right+20, y: 0, width: contentView.width-imageView.width-20, height: 50)
//        moreButton.frame = CGRect(x: contentView.width-moreButton.width-10, y: 10, width: 50, height: 50)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    func configure(with viewModel: PostLinkDateCollectionCellViewModel) {
        label.text = (viewModel.dateString)
    }
}


