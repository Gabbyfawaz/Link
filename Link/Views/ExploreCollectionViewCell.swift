//
//  ExploreCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/08/20.
//

import UIKit

class ExploreCollectionViewCell: UICollectionViewCell {
    static let identifier = "ExploreCollectionViewCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .label
        return imageView
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = .label
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(iconImageView)
        contentView.insertSubview(label, at: 1)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        iconImageView.frame = CGRect(x: 10,
                                     y: height-40-10,
                                     width: 40,
                                     height: 40)
        label.frame = CGRect(x: iconImageView.right+10,
                             y: height-40-5,
                             width: width-50,
                             height: 40)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }


    

    func configure(postString: String, iconString: String, nameOfLink: String ) {
        imageView.sd_setImage(with: URL(string: postString), completed: nil)
        iconImageView.sd_setImage(with: URL(string: iconString), completed: nil)
        label.text = nameOfLink
    }
}
