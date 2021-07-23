//
//  PostLocationCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

protocol PostLocationCollectionViewCellDelegate: AnyObject {
    func postLocationCollectionViewCellDidTapLocation(_ cell: PostLocationCollectionViewCell, index: Int)
}


final class PostLocationCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostLocationCollectionViewCell"
    
    weak var delegate: PostLocationCollectionViewCellDelegate?

    var index = 0
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private let locationImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "mappin.and.ellipse")
        iv.isUserInteractionEnabled = true
        iv.tintColor = .label
        return iv
    }()
    
//    private let lockImageView: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(systemName: "lock.fill")
//        iv.isUserInteractionEnabled = true
//        iv.tintColor = .label
//        return iv
//    }()
    
//    private let locationTitlelabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.isUserInteractionEnabled = true
//        label.text = "LOCATION:"
//        label.font = .systemFont(ofSize: 21, weight:.bold)
//        return label
//    }()

    private let locationlabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(locationlabel)
//        contentView.addSubview(lockImageView)
//        contentView.addSubview(locationTitlelabel)
        contentView.addSubview(locationImageView)
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapLocation))
        locationlabel.addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc func didTapLocation() {
   
        delegate?.postLocationCollectionViewCellDidTapLocation(self, index: index)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        let size = label.sizeThatFits(CGSize(width: contentView.bounds.size.width-12,
//                                             height: contentView.bounds.size.height))
        
//        imageView.frame = CGRect(x: 10, y: 0, width: contentView.width-20, height: contentView.height)
//        imageView.layer.cornerRadius = 20
//        imageView.sendSubviewToBack(locationlabel)
        locationImageView.frame = CGRect(x: 15, y: 5, width: 40, height: 40)
        locationlabel.frame = CGRect(x: locationImageView.right+20+10, y: 10, width: (contentView.width-110), height: 40)
//        lockImageView.frame = CGRect(x: contentView.width-locationImageView.width, y: 7, width: 40, height: 40)
//        locationlabel.frame = CGRect(x: 20, y: locationTitlelabel.bottom, width: (contentView.width-50), height: contentView.height-locationTitlelabel.height)
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        locationlabel.text = nil
    }

    func configure(with viewModel: PostLocationCollectionViewCellViewModel, index: Int) {
        self.index = index
        locationlabel.text = "\(viewModel.location ?? "")"
        
        if viewModel.isPrivate == true {
            locationlabel.text = "Private"
        }
//            lockImageView.image = UIImage(systemName: "lock.fill")
//        } else {
//            lockImageView.image = UIImage(systemName: "lock.open.fill")
//        }
    }

}

