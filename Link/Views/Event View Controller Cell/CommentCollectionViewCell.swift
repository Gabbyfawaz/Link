//
//  CommentCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

class CommentCollectionViewCell: UITableViewCell {
    static let identifier = "CommentCollectionViewCell"

    
   
    private let profileImageView: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        return image
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(profileImageView)
        // Add constraints
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: contentView.topAnchor),
//            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        label.sizeToFit()
        
        
        profileImageView.frame = CGRect(x: 15, y: (contentView.height-profileImageView.height-10)/2, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 20
        label.frame = CGRect(x: profileImageView.right+10, y: (contentView.height-profileImageView.height-10)/2, width: contentView.width-15-profileImageView.width, height: contentView.height)
    }

    func configure(with model: Comment) {
        label.text = "\(model.username): \(model.comment)"
        print("The person's model name: \(model.username)")
        
        
        DispatchQueue.main.async {
            StorageManager.shared.profilePictureURL(for: model.username) { url in
                guard let url = url else {
                    return
                }
                
                self.profileImageView.sd_setImage(with: url, completed: nil)
                
            }
        }
       
    }
}

