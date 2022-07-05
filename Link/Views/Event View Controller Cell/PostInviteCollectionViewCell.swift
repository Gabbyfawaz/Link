//
//  PostInviteCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//


import UIKit

protocol PostInviteCollectionViewCellDelegate: AnyObject {
    func postInviteCollectionViewCell(_ cell: PostInviteCollectionViewCell, username: String)
}


 final class PostInviteCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
     
    static let identifier = "PostInviteCollectionViewCell"
    weak var delegate: PostInviteCollectionViewCellDelegate?

    // MARK: PROPERTIES
    
    private var observer: NSObjectProtocol?
    private var pendingUsers = [SearchUser]()
    private var confirmedUsers = [SearchUser]()
    private var usersArray = [SearchUser]()
    private var actionButton = NameOfLinkCollectionCellViewActions.request(isRequested: false)
    

    private var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 15
        return stack
    }()
    
    
    private let pendingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        button.tintColor = .label
        button.layer.masksToBounds = true
//        button.layer.cornerRadius = 8
//        button.layer.borderWidth = 2
//        button.layer.borderColor = UIColor.label.cgColor
        return button
    }()
    
    private let confirmedButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.layer.masksToBounds = true
//        button.layer.cornerRadius = 8
//        button.layer.borderWidth = 2
//        button.layer.borderColor = UIColor.label.cgColor
        return button
    }()
    
     
//     private let changeCollectionView: UIButton = {
//         let button = UIButton()
//         button.backgroundColor = .label
//         button.setTitle("PENDING", for: .normal)
//         button.titleLabel?.lineBreakMode = .byCharWrapping
//         button.titleLabel?.font = .systemFont(ofSize: 10)
//         button.setTitleColor(.systemBackground, for: .normal)
//         button.layer.masksToBounds = true
//         button.layer.cornerRadius = 8
//         button.layer.masksToBounds = true
//         return button
//     }()
    
    private var peopleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 80, height: 80)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AddUsersToLinkCollectionViewCell.self,
                                forCellWithReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier)
        return collectionView
    }()
    
    
    //MARK: LIFECYCLE

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.masksToBounds = true
        backgroundColor = .systemBackground
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(pendingButton)
        verticalStackView.addArrangedSubview(confirmedButton)
        
        addSubview(peopleCollectionView)
        peopleCollectionView.delegate = self
        peopleCollectionView.dataSource = self
        confirmedButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        pendingButton.addTarget(self, action: #selector(didTapPending), for: .touchUpInside)

    
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

  

    //MARK: LAYOUT SUBVIEWS


    override func layoutSubviews() {
        super.layoutSubviews()
        
        let paddingWidth = width - height/4 - 30
        peopleCollectionView.frame = CGRect(x: width-paddingWidth-5, y: 0, width: paddingWidth, height: contentView.height)
        verticalStackView.frame = CGRect(x: 15, y: 20, width: height/4, height: height/2)
       
    }

    

    //MARK: ACTIONS FOR BUTTONS
    
    @objc func didTapConfirm() {
        self.usersArray = self.confirmedUsers
        DispatchQueue.main.async {
            self.peopleCollectionView.reloadData()
        }
    }

    @objc func didTapPending() {
        self.usersArray = self.pendingUsers
        DispatchQueue.main.async {
            self.peopleCollectionView.reloadData()
        }
        
    }

    
    // MARK: CONFIGUREUI
        
        func configure(with viewModel: PostInviteCollectionViewCellViewModel) {
            DispatchQueue.main.async {
                self.peopleCollectionView.reloadData()
            }
            self.pendingUsers = viewModel.pendingUsers
            self.confirmedUsers = viewModel.confirmedUsers
            self.usersArray = pendingUsers
        }
    
    //MARK: - CollectionViewDataSource/Delegate

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of users selected\(pendingUsers.count)")
        return usersArray.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = usersArray[indexPath.row]
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


extension PostInviteCollectionViewCell: AddUsersToLinkCollectionViewCellDelegate {
    
    func PostInviteCollectionViewCell(_ cell: AddUsersToLinkCollectionViewCell, username: String) {
        delegate?.postInviteCollectionViewCell(self, username: username)
    }
    
    
}
