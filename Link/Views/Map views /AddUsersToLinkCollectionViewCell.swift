//
//  AddUsersToLinkCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

protocol AddUsersToLinkCollectionViewCellDelegate: AnyObject {
    func PostInviteCollectionViewCell( _ cell: AddUsersToLinkCollectionViewCell, username: String)
}

class AddUsersToLinkCollectionViewCell: UICollectionViewCell {
    
    private var profileURL: URL?
    static let identifier = "AddUsersToLinkCollectionViewCell"
    weak var delegate: AddUsersToLinkCollectionViewCellDelegate?
    private var username: String?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .black
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(imageView)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tap)
        
     
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        

        
        label.sizeToFit()
        label.frame = CGRect(x: (0), y: 80-14, width: 80, height: 10)

        let imageSize: CGFloat = 80-10-4
        imageView.layer.cornerRadius = imageSize/2
        imageView.frame = CGRect(x: (80-imageSize)/2, y: 0, width: imageSize, height: imageSize)
        
 
    }
    
    @objc func didTapImage() {
        guard let username = username else {
            return
        }
        
        delegate?.PostInviteCollectionViewCell(self, username: username)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = nil
    }

    func configure(with viewModel: SearchUser) {
//        label.text = viewModel.name
        self.username = viewModel.name
        
        StorageManager.shared.profilePictureURL(for: viewModel.name) { [weak self] url in
            guard  let profileURL = url else {
                return
                
            }
            DispatchQueue.main.async {
                self?.imageView.sd_setImage(with: profileURL, completed: nil)
                self?.label.text = viewModel.name
            }
//            self?.profileURL = profileURL
        }
    }
}

