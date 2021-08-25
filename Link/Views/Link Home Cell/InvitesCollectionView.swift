//
//  InvitesCollectionView.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/31.
//

import UIKit

class InvitesCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {


    private var userArray = [SearchResult]()
    
//    private let invitelabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.text = "INVITED:"
//        label.font = .systemFont(ofSize: 21, weight: .bold)
//        return label
//    }()
    
    private var horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    private var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    private let pendingNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "20 PENDING"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .bold)
//        label.layer.borderWidth = 2
//        label.layer.borderColor = UIColor.black.cgColor
//        label.backgroundColor = .black
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.backgroundColor = #colorLiteral(red: 0.8822453618, green: 0.8364266753, blue: 0.9527176023, alpha: 1)
      
        return label
    }()
    
    private let confirmedNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "10 CONFIRMED"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .bold)
//        label.layer.borderWidth = 2
//        label.layer.borderColor = UIColor.black.cgColor
//        label.backgroundColor = .black
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.backgroundColor = #colorLiteral(red: 0.8822453618, green: 0.8364266753, blue: 0.9527176023, alpha: 1)
        label.layer.shadowColor = UIColor.black.cgColor
       
        return label
    }()
    
    
    private let pendingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "slowmo"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.tintColor = .black
        return button
    }()
    
    private let confirmedButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.tintColor = .black
        return button
    }()
    
    
    private let commentsLabel: UILabel = {
        let label = UILabel()
        label.text = "View Comments"
        label.textAlignment = .left
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        return label
    }()
    
    private let actualDate: UILabel = {
        let label = UILabel()
        label.text = "7th August 2021"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
    
        return label
    }()
    
    private var dateVerticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 1
        stack.layer.masksToBounds = true
        stack.layer.cornerRadius = 8
        stack.backgroundColor = #colorLiteral(red: 0.8822453618, green: 0.8364266753, blue: 0.9527176023, alpha: 1)
        return stack
    }()
    
    
    
    
    private let peopleInvitedButton: UIButton = {
        let barButton = UIButton()
        barButton.setImage(UIImage(systemName: "person.2.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        barButton.tintColor = .label
        return barButton
    }()

    private var peopleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 100, height: 100)
//        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
//        collectionView.layer.borderWidth = 2
//        collectionView.layer.borderColor = UIColor.label.cgColor
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AddUsersToLinkCollectionViewCell.self,
                                forCellWithReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier)
        return collectionView
    }()
    



    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = .systemBackground
        addSubview(peopleCollectionView)
        addSubview(peopleInvitedButton)
        peopleCollectionView.delegate = self
        peopleCollectionView.dataSource = self
        
        addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(pendingNumberLabel)
        horizontalStackView.addArrangedSubview(confirmedNumberLabel)
        
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(pendingButton)
        verticalStackView.addArrangedSubview(confirmedButton)
        
        addSubview(commentsLabel)
        
        addSubview(dateVerticalStackView)
        dateVerticalStackView.addArrangedSubview(dateLabel)
        dateVerticalStackView.addArrangedSubview(actualDate)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }



    override func layoutSubviews() {
        super.layoutSubviews()

//        peopleInvitedButton.frame = CGRect(x: 15, y: 20, width: 50, height: 50)
        peopleCollectionView.frame = CGRect(x: 15+50+10, y: 60, width: width-30, height: 100)
//        peopleCollectionView.layer.cornerRadius = 20
        
        horizontalStackView.frame = CGRect(x: 15,
                                 y: 5,
                                 width: width-30,
                                 height: 30)
        
        verticalStackView.frame = CGRect(x: 15,
                                         y: 60,
                                         width: 50,
                                         height: 100)
        commentsLabel.frame = CGRect(x: 15,
                                     y: 160+40,
                                    width: 120,
                                    height: 20)
        
        dateVerticalStackView.frame = CGRect(x: width-15-100,
                                             y: 160+20,
                                             width: 100,
                                             height: 40)
        
       
    }



    func configure(with viewModel: PostOfFeedCollectionViewModel) {
        self.userArray = viewModel.invite
        actualDate.text = viewModel.date
        
        
    }
    
    
    //MARK: - CollectionViewDataSource/Delegate

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of users selected\(userArray.count)")
        return userArray.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = userArray[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier,
                for: indexPath
        ) as? AddUsersToLinkCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: model)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: peopleCollectionView.height, height: peopleCollectionView.height)
    }

}
