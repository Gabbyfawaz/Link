//
//  QuickLinkTableViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 16/03/2022.
//

import UIKit

class QuickLinkTableViewCell: UITableViewCell {
    
    static let identifier = "QuickLinkTableViewCell"

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
//        imageView.backgroundColor = .none
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
//        label.backgroundColor = .none
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        contentView.backgroundColor = .none
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
       
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.frame = CGRect(x: 10,
                                     y: 7.5,
                                     width: 50,
                                     height: 50)

        userNameLabel.frame = CGRect(x: userImageView.right + 5,
                                     y: 17.5,
                                     width: contentView.width - 20 - 50,
                                     height: 30)
    }


    public func configure(with model: SearchUser) {

        StorageManager.shared.profilePictureURL(for: model.name) { [weak self] url in
            guard  let profileURL = url else {
                return
                
            }
            DispatchQueue.main.async {
                self?.userImageView.sd_setImage(with: profileURL, completed: nil)
            }
        }
        self.userNameLabel.text = model.name
    }

}
