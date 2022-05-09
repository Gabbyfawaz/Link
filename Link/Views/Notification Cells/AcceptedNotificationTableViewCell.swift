//
//  AcceptedNotificationTableViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/09/07.
//

import UIKit

protocol AcceptedNotificationTableViewCellDelegate: AnyObject {
    func acceptedNotificationTableViewCell(_ cell: AcceptedNotificationTableViewCell,
                                       didTapPostWith viewModel: AcceptedRequestNotificationCellViewModel)
}

class AcceptedNotificationTableViewCell: UITableViewCell {
    static let identifer = "AcceptedNotificationTableViewCell"

    weak var delegate: AcceptedNotificationTableViewCellDelegate?

    private var viewModel: AcceptedRequestNotificationCellViewModel?

    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .tertiarySystemBackground
        return imageView
    }()

    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(postImageView)

        postImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPost))
        postImageView.addGestureRecognizer(tap)
        contentView.addSubview(dateLabel)
    }

    @objc func didTapPost() {
        guard let vm = viewModel else {
            return
        }
        delegate?.acceptedNotificationTableViewCell(self,
                                                didTapPostWith: vm)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height/1.5
        profilePictureImageView.frame = CGRect(
            x: 10,
            y: (contentView.height-imageSize)/2,
            width: imageSize,
            height: imageSize
        )
        profilePictureImageView.layer.cornerRadius = imageSize/2

        let postSize: CGFloat = contentView.height - 6
        postImageView.frame = CGRect(
            x: contentView.width-postSize-10,
            y: 3,
            width: postSize,
            height: postSize
        )

        let labelSIze = label.sizeThatFits(
            CGSize(
                width: contentView.width-profilePictureImageView.right-25-postSize,
                height: contentView.height
            )
        )
        dateLabel.sizeToFit()
        label.frame = CGRect(
            x: profilePictureImageView.right+10,
            y: 0,
            width: labelSIze.width,
            height: contentView.height-dateLabel.height-2
        )
        dateLabel.frame = CGRect(
            x: profilePictureImageView.right+10,
            y: contentView.height-dateLabel.height-2,
            width: dateLabel.width,
            height: dateLabel.height
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profilePictureImageView.image = nil
        postImageView.image = nil
        dateLabel.text = nil
    }

    public func configure(with viewModel: AcceptedRequestNotificationCellViewModel) {
        self.viewModel = viewModel
        StorageManager.shared.profilePictureURL(for: viewModel.username) { url in
            DispatchQueue.main.async {
                if let url = url {
                    self.profilePictureImageView.sd_setImage(with: url, completed: nil)
                }
            }
        }
        postImageView.sd_setImage(with: viewModel.postUrl, completed: nil)
        label.text = viewModel.username + " accepted your invite."
        dateLabel.text = viewModel.date
    }
}


