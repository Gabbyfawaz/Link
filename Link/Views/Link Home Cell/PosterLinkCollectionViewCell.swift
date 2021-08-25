//
//  PosterlinkCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit


protocol PosterLinkCollectionViewCellDelegate: AnyObject {
    func posterLinkCollectionViewCellDidTapRequest(_ cell: PosterLinkCollectionViewCell, index: Int)
}

final class PosterLinkCollectionViewCell: UICollectionViewCell {
    static let identifier = "PosterlinkCollectionViewCell"

    //MARK: -  Properties
    
    private var index = 0
    private var isRequested = false
    weak var delegate: PosterLinkCollectionViewCellDelegate?
    
    private let typeOfLink: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
     private var requestButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = myPurple
        button.setTitle("Request", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(typeOfLink)
        contentView.addSubview(requestButton)
        requestButton.addTarget(self, action: #selector(didTapRequest), for: .touchUpInside)

    }
    
    //MARK: - Actions
    
    @objc private func didTapRequest() {
        
        isRequested = !isRequested
        
        
        if isRequested {
            requestButton.setTitle("Requesting", for: .normal)
            requestButton.backgroundColor = .lightGray
            requestButton.layer.borderColor = UIColor.secondarySystemBackground.cgColor
            //                requestButtom.layer.borderWidth = 3
            print(isRequested)
        } else {
            requestButton.setTitle("Request", for: .normal)
            requestButton.backgroundColor = myPurple
            print(isRequested)
        }
        
        
        delegate?.posterLinkCollectionViewCellDidTapRequest(self, index: index)
        
    }
    
  
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

        typeOfLink.sizeToFit()
        typeOfLink.frame = CGRect(
            x: 20,
            y: 0,
            width: typeOfLink.width,
            height: typeOfLink.height
        )
        

        requestButton.frame = CGRect(x: contentView.width-120-20, y: 0, width: 120, height: 30)

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ConfigureUI
    func configure(with viewModel: PosterLinkCollectionViewCellViewModel) {
        
        typeOfLink.text = viewModel.linkType

    }
    
}

