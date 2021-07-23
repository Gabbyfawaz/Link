//
//  PostInviteCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//


import UIKit

final class PostInviteCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    static let identifier = "PostInviteCollectionViewCell"

    private var userArray = [SearchResult]()
    
//    private let invitelabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.text = "INVITED:"
//        label.font = .systemFont(ofSize: 21, weight: .bold)
//        return label
//    }()
    
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
        layout.itemSize = CGSize(width: 80, height: 80)
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
        
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(peopleCollectionView)
        contentView.addSubview(peopleInvitedButton)
        peopleCollectionView.delegate = self
        peopleCollectionView.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError()
    }



    override func layoutSubviews() {
        super.layoutSubviews()

        peopleInvitedButton.frame = CGRect(x: 15, y: 20, width: 50, height: 50)
        peopleCollectionView.frame = CGRect(x: peopleInvitedButton.right+20, y: 2+5, width: contentView.width-30-peopleInvitedButton.width-15, height: contentView.height-20)
        peopleCollectionView.layer.cornerRadius = 20
       
    }

    override func prepareForReuse() {
        super.prepareForReuse()
      
    }

    func configure(with viewModel: PostInviteCollectionViewCellViewModel) {
        self.userArray = viewModel.invites
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

