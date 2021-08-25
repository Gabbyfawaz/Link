//
//  PostLinkDateCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//


import UIKit


final class PostLinkDateCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostLinkDateCollectionViewCell"
    private var count = 10
//    private let imageView: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(systemName: "calendar")
//        iv.tintColor = .black
//        return iv
//    }()
    
    
    private let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()
    
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "DATE"
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = myPurple
        label.backgroundColor = .systemBackground
        label.numberOfLines = 0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderColor = myPurple.cgColor
        label.layer.borderWidth = 2
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let countDownLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = myPurple
        label.backgroundColor = .systemBackground
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderColor = myPurple.cgColor
        label.layer.borderWidth = 2

        return label
    }()
    
    
    //MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(mainLabel)
        contentView.addSubview(horizontalStack)
        horizontalStack.addArrangedSubview(dateLabel)
        horizontalStack.addArrangedSubview(countDownLabel)
        
        
//        var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
//

    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    

    //MARK: - Actions
    
//    @objc func update() {
//
//        if count > 0 {
//            print("\(count) seconds to the end of the world")
//            countDownLabel.text = String(count)
//            count -= 1
//        } else {
//            countDownLabel.text = String(0)
//        }
//
//    }

    //MARK: - Layout Subviews

    override func layoutSubviews() {
        super.layoutSubviews()

//        dateLabel.sizeToFit()
        mainLabel.sizeToFit()
        mainLabel.frame = CGRect(x: 17, y: 10, width: mainLabel.width, height: mainLabel.height)
        horizontalStack.frame = CGRect(x: 15, y: mainLabel.bottom+5, width: contentView.width-30, height: 50)

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        countDownLabel.text = nil
    }

    func configure(with viewModel: PostLinkDateCollectionCellViewModel) {
        dateLabel.text = (viewModel.dateString)
        countDownLabel.text = "10 Days Left"
    }
}


