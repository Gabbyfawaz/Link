//
//  RequestNotificationTableViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/09/05.
//

import UIKit


protocol RequestNotificationTableViewCellDelegate: AnyObject {
    func requestNotificationTableViewCell(_ cell: RequestNotificationTableViewCell,
                                         didTapButton isRequest: Bool,
                                         viewModel: RequestNotificationCellViewModel)
}

final class RequestNotificationTableViewCell: UITableViewCell {
    static let identifer = "RegisterNotificationTableCell"

    weak var delegate: RequestNotificationTableViewCellDelegate?

    private var viewModel: RequestNotificationCellViewModel?

    private var didAccept = false

    private let linkIconPictureImageView: UIImageView = {
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

    private let acceptButton = LinkAcceptButton()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(linkIconPictureImageView)
        contentView.addSubview(acceptButton)
        contentView.addSubview(dateLabel)
        acceptButton.addTarget(self, action: #selector(didTapAcceptButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc func didTapAcceptButton() {
        guard let vm = viewModel else {
            return
        }
        delegate?.requestNotificationTableViewCell(self, didTapButton: !didAccept, viewModel: vm)
        didAccept = !didAccept

        acceptButton.configure(for: didAccept ? .accepted : .accept)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height/1.5
        linkIconPictureImageView.frame = CGRect(
            x: 10,
            y: (contentView.height-imageSize)/2,
            width: imageSize,
            height: imageSize
        )
        linkIconPictureImageView.layer.cornerRadius = imageSize/2

        acceptButton.sizeToFit()
        let buttonWidth: CGFloat = max(acceptButton.width, 75)
        acceptButton.frame = CGRect(
            x: contentView.width - buttonWidth - 24,
            y: (contentView.height - acceptButton.height)/2,
            width: buttonWidth + 14,
            height: acceptButton.height
        )

        let labelSIze = label.sizeThatFits(
            CGSize(
                width: contentView.width-linkIconPictureImageView.width-buttonWidth-44,
                height: contentView.height
            )
        )
        dateLabel.sizeToFit()

        label.frame = CGRect(
            x: linkIconPictureImageView.right+10,
            y: 0,
            width: labelSIze.width,
            height: contentView.height-dateLabel.height-2
        )
        dateLabel.frame = CGRect(
            x: linkIconPictureImageView.right+10,
            y: contentView.height-dateLabel.height-2,
            width: dateLabel.width,
            height: dateLabel.height
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        linkIconPictureImageView.image = nil
        acceptButton.setTitle(nil, for: .normal)
        acceptButton.backgroundColor = nil
        dateLabel.text = nil
    }

    public func configure(with viewModel: RequestNotificationCellViewModel) {
        self.viewModel = viewModel
        print(viewModel)
        label.text = viewModel.username + " requested to join your link."
        linkIconPictureImageView.sd_setImage(with: viewModel.linkIconPictureUrl, completed: nil)
        didAccept = viewModel.isRequested
        dateLabel.text = viewModel.date

        acceptButton.configure(for: didAccept ? .accepted : .accept)
    }
}


