//
//  PostLinkExtraInfoCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

protocol PostLinkExtraInfoCollectionViewCellDelegate: AnyObject{
    func postLinkExtraInfoCollectionViewCellDidTapUsername(_ cell: PostLinkExtraInfoCollectionViewCell)
}
final class PostLinkExtraInfoCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostLinkExtraInfoCollectionViewCell"
    
    weak var delegate: PostLinkExtraInfoCollectionViewCellDelegate?
    
//    private let infoLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.isUserInteractionEnabled = true
//        label.text = "Info"
//        label.font = .systemFont(ofSize: 30, weight: .medium)
//        return label
//    }()
//
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.text = "jamie:"
        return label
    }()
    


    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(usernameLabel)
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapInfo))
        usernameLabel.addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
//    @objc private func didTapMore() {
////        delegate?.postInfoCollectionViewCellDidTapMoreButton(self, index: index)
//    }

    @objc func didTapInfo() {
        delegate?.postLinkExtraInfoCollectionViewCellDidTapUsername(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        usernameLabel.sizeToFit()
        usernameLabel.frame = CGRect(x: 15, y: 10, width: usernameLabel.width, height: usernameLabel.height)
       
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
    }

    func configure(with viewModel: PostLinkUsenameCollectionCellViewModel) {
        usernameLabel.text = "\(viewModel.username):"
    }
}

