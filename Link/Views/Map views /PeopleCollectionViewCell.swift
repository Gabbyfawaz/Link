//
//  PeopleCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//
import UIKit

class PeopleCollectionViewCell: UICollectionViewCell {
    
    private var peopleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .purple
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AddUsersToLinkCollectionViewCell.self,
                                forCellWithReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier)
        return collectionView
    }()
    
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 1
            //viewModels.count
        }


        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier,
                    for: indexPath
            ) as? AddUsersToLinkCollectionViewCell else {
                fatalError()
            }
            //cell.configure(with: viewModels[indexPath.row])
            return cell
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 100, height: 100)
        }
        
    }

