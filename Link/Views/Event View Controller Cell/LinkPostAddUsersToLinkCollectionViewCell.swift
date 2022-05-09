//
//  LinkPostAddUsersToLinkCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation

import UIKit

class LinkPostAddUsersToLinkCollectionViewCell: UICollectionViewCell {
    
    private var profileURL: URL?
    static let identifier = "LinkPostAddUsersToLinkCollectionViewCell"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .black
        imageView.tintColor = .black
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        label.tintColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
//         let imageSize = contentView.height-label.height-10
//        imageView.frame = CGRect(x: 5, y: 2, width: imageSize, height: imageSize)
//        imageView.layer.cornerRadius = imageSize/2
//        label.frame = CGRect(x: 7, y: imageView.bottom+10, width: imageView.width, height: 20)
        
        label.sizeToFit()
        label.frame = CGRect(x: 5, y: contentView.height-label.height, width: contentView.width, height: label.height)

        let imageSize: CGFloat = contentView.height-label.height-4
        imageView.layer.cornerRadius = imageSize/2
        imageView.frame = CGRect(x: (contentView.width-imageSize)/2, y: 0, width: imageSize, height: imageSize)
        
//
//        label.sizeToFit()
//        label.frame = CGRect(x: 10, y: imageView.bottom+42, width: imageView.width+50, height: label.height)
//
//        let imageSize: CGFloat = contentView.height-label.height+10
//        imageView.layer.cornerRadius = imageSize/2
//        imageView.frame = CGRect(x: 5, y: 0, width: imageSize, height: imageSize)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = nil
    }

    func configure(with viewModel: SearchResult) {
        label.text = viewModel.name

        StorageManager.shared.profilePictureURL(for: viewModel.name) { [weak self] url in
            guard  let profileURL = url else {
                return

            }
            self?.profileURL = profileURL
        }

        DispatchQueue.main.async {
            self.imageView.sd_setImage(with: self.profileURL, completed: nil)
        }
////
////        print(label.text)
////        print(profileURL)
//
    }
}

