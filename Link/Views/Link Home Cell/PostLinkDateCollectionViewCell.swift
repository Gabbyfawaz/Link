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
        label.textColor = .black
        label.backgroundColor = .systemBackground
        label.numberOfLines = 0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderColor =  UIColor.black.cgColor
        label.layer.borderWidth = 1
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let countDownLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .systemBackground
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1

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
        horizontalStack.frame = CGRect(x: 15, y: mainLabel.bottom+5, width: contentView.width-30, height: 30)

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        countDownLabel.text = nil
        dateLabel.text = nil
    }

    func configure(with viewModel: PostLinkDateCollectionCellViewModel) {
        
        dateLabel.text = viewModel.dateString
        
        guard let dateString = viewModel.dateString else {
             return
         }
        
           
        let formatter = DateFormatter()
        guard let date = DateFormatter.formatter.date(from: dateString) else {
            return
        }
       
        formatter.dateFormat = "dd.MM.yyyy"
           formatter.dateFormat = "dd"
           let day = formatter.string(from: date)
           print(day)
        
   
        
         let formatter2 = DateFormatter()
         formatter2.dateFormat = "dd.MM.yyyy"
            formatter2.dateFormat = "dd"
            let day2 = formatter.string(from: Date())
            print(day2)
        
        
        guard let numberDay2 = Int(day2), let numberDay1 = Int(day) else {
            return
        }
        
        let numberOfDaysLeft = numberDay2-numberDay1
     
        if numberOfDaysLeft >= 0 {
            countDownLabel.text = "\(numberOfDaysLeft) Days Left"
        } else {
            countDownLabel.text = "LINK Completed"
        }
        
        

    }
}


