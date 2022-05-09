//
//  CustomizedHeaderViewForInvites.swift
//  Link
//
//  Created by Gabriella Fawaz on 17/01/2022.
//

import UIKit
class CustomizedHeaderViewForInvites: UITableViewHeaderFooterView {
    
    static let identifier = "sectionHeader"
    private let usersAddedToCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: 90, height: 90)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isHidden = false
        collectionView.register(AddUsersToLinkCollectionViewCell.self,
                                forCellWithReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier)
        return collectionView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.tintColor = .label
        label.textAlignment = .center
        return label
    }()
    
//    private var targetUserDataArray = [SearchResult]()
    private var targetUserDataArray = [SearchUser]()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(usersAddedToCollectionView)
        addSubview(usernameLabel)
        usersAddedToCollectionView.delegate = self
        usersAddedToCollectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        usersAddedToCollectionView.frame = CGRect(x: 0, y: 0, width: contentView.width, height: contentView.height-10)
        usernameLabel.frame = CGRect(x: 0, y: usersAddedToCollectionView.frame.height+5, width: contentView.width, height: 15)
        
    }
    
    public func configure(with targetUserDataArray: [SearchUser]) {
        self.targetUserDataArray = targetUserDataArray
        usersAddedToCollectionView.reloadData()
        print("The results recieved from the header view: \(targetUserDataArray)")
    }
    
}

extension CustomizedHeaderViewForInvites: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return targetUserDataArray.count
        
    }
  
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let model = self.targetUserDataArray[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier, for: indexPath) as? AddUsersToLinkCollectionViewCell else {
            fatalError("Error trouble dequeing cell")
            
        }
        cell.configure(with: model)
            return cell
        }
}
