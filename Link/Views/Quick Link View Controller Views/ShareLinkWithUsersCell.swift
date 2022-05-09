//
//  file.swift
//  Link
//
//  Created by Gabriella Fawaz on 02/03/2022.
//

import UIKit
import SDWebImage

protocol ShareLinkWithUsersCellDelegate: AnyObject {
    func ShareLinkWithUsersCellDidiTapShareButton(_ cell: ShareLinkWithUsersCell)
}

class ShareLinkWithUsersCell: UITableViewCell {
    
    static var identifier = "ShareLinkWithUsersCell"
    weak var delegate: ShareLinkWithUsersCellDelegate?
    private var profileURL: URL?


    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = 5
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(shareButton)
        shareButton.addTarget(self, action: #selector(didShareButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 50,
                                     height: 50)

        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 20,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: 30)
        shareButton.frame = CGRect(x: (width-70-10), y: 20, width: 70, height: 30)
    }

    
    //MARK: ACTIONS
    
    @objc func didShareButton() {
        
        shareButton.setTitle("Sent", for: .normal)
        shareButton.setTitleColor(.systemYellow, for: .normal)
        shareButton.backgroundColor = .systemBackground
        shareButton.layer.borderWidth = 1
        shareButton.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        
        delegate?.ShareLinkWithUsersCellDidiTapShareButton(self)
    }
    
    
    
    public func configure(with model: SearchUser) {
         
   
        StorageManager.shared.profilePictureURL(for: model.name) { [weak self] profileUrl in
            guard  let profileURL = profileUrl else {
                return
                
            }
//            self?.profileURL = profileURL
            
            DispatchQueue.main.async {
                self?.userImageView.sd_setImage(with: profileURL, completed: nil)
                self?.userNameLabel.text = model.name
            }
        }
        
//        DispatchQueue.main.async {
//            self.userImageView.sd_setImage(with: self.profileURL, completed: nil)
//        }
        
    }

}

