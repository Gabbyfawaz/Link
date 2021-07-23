//
//  NameofLinkCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import FirebaseAuth



final class NameofLinkCollectionViewCell: UICollectionViewCell {
    static let identifier = "NameofLinkCollectionViewCell"

    //MARK: -  Properties
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .systemBackground
//        imageView.image?.withTintColor(.white)
        return imageView
    }()

    private let typeOfLink: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
//    private let moreButton: UIButton = {
//        let button = UIButton()
//        button.tintColor = .label
//        let image = UIImage(systemName: "ellipsis",
//                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
//        button.setImage(image, for: .normal)
//        return button
//    }()

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(typeOfLink)
  
    
    }
    
    //MARK: - Actions
    
    @objc private func didTapProfileImage() {
        
   /// go to users page
    }
    
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imagePadding: CGFloat = 4
        let imageSize: CGFloat = contentView.height - (imagePadding * 4)
        imageView.frame = CGRect(x: 15, y: imagePadding+4, width: imageSize, height:imageSize)
        imageView.layer.cornerRadius = imageSize/2

        typeOfLink.sizeToFit()
        typeOfLink.frame = CGRect(
            x: imageView.right+10,
            y: 5,
            width: typeOfLink.width,
            height: contentView.height
        )
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ConfigureUI
    func configure(with viewModel: NameOfCollectionViewViewModel, index: Int) {
        
        // add index parameter
        typeOfLink.text = viewModel.linkType

        imageView.sd_setImage(with: viewModel.linkTypeImage, completed: nil)
//        imageView.image?.sd_colors(with: [UIColor(white: 1, alpha: 1)])
            }
    
}


