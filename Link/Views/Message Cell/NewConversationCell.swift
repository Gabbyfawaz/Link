//
//  NewConversationCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import SDWebImage

class NewConversationCell: UITableViewCell {
    
    private var profileURL: URL?
    
    static let identifier = "NewConversationCell"

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 70,
                                     height: 70)

        userNameLabel.frame = CGRect(x: userImageView.bottom + 5,
                                     y: 20,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: 50)
    }

    
    public func configure(with model: SearchResult) {

        StorageManager.shared.profilePictureURL(for: model.name) { [weak self] url in
            guard  let profileURL = url else {
                return
            }
            self?.profileURL = profileURL
        }
        DispatchQueue.main.async {
            self.userImageView.sd_setImage(with: self.profileURL, completed: nil)
        }
        userNameLabel.text = model.name
    }
    
    
    
    public func configure(with model: SearchUser) {
       userNameLabel.text = model.name
        StorageManager.shared.profilePictureURL(for: model.name) { [weak self] url in
            guard  let profileURL = url else {
                return
                
            }
            DispatchQueue.main.async {
                self?.userImageView.sd_setImage(with: profileURL, completed: nil)
            }
        }
    }

}

