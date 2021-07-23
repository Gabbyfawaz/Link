//
//  MapViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import MapKit


class MapViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    

    //MARK: - Properties
    private var collectionView: UICollectionView?

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        title = "LINK"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isHidden = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        configureCollectionView()
        

    }
    
    //MARK: - LayoutSubviews

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    
   //MARK: -  Create collectionView
    
    private func configureCollectionView() {
        let collectionView = UICollectionView(
            frame: .zero,collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in

                // Item
                let mapItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)))

                // Group
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)),subitem: mapItem, count: 1
                )

                // Section
                let section = NSCollectionLayoutSection(group: group)

                if index == 0 {
                    section.boundarySupplementaryItems = [
                        NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: NSCollectionLayoutSize(
                                widthDimension: .fractionalWidth(1),
                                heightDimension: .fractionalWidth(0.3)
                            ),
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top
                        )
                    ]
                }

                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom:10, trailing: 0)

                return section
            })
        )

        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self


        collectionView.register(MapCollectionViewCell.self,
            forCellWithReuseIdentifier: MapCollectionViewCell.identifier)

        collectionView.register(StoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: StoryHeaderView.identifier)

        self.collectionView = collectionView
    }
        
    
    //MARK: - CollectionViewDelegate/DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MapCollectionViewCell.identifier,
                for: indexPath
            ) as? MapCollectionViewCell else {
                fatalError()
            }
        cell.viewContainer.delegate = self
        cell.delegate = self
        return cell
        }

    //MARK: - CollectionViewHeaderDelegate/DataSource
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: StoryHeaderView.identifier,
                for: indexPath
              ) as? StoryHeaderView else {
            return UICollectionReusableView()
        }
        let viewModel = StoriesViewModel(stories: [
            Story(username: "jeffbezos", image: UIImage(named: "story1")),
            Story(username: "simon12", image: UIImage(named: "story2")),
            Story(username: "marqueesb", image: UIImage(named: "story3")),
            Story(username: "kyliejenner", image: UIImage(named: "story4")),
            Story(username: "drake", image: UIImage(named: "story5")),
        ])
        headerView.configure(with: viewModel)
        return headerView
    }
    


}




//MARK: - HomeContainerProtocols
extension MapViewController: HomeMapViewContainerProtocols {
    
    func homeMapViewContainerDidTapMessages(_ container: HomeMapViewContainer) {
        let vc = ConversationsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func homeMapViewContainerDidTapCreateLink(_ container: HomeMapViewContainer) {
        let vc = LinkCameraViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func homeMapViewContainerDidTapLinkNotifications(_ container: HomeMapViewContainer) {
        let vc = LinkNotificationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func homeMapViewContainerDidTapNotifications(_ container: HomeMapViewContainer) {
        let vc = NotificationsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
        


}

extension MapViewController: MapCollectionViewCellDelegate {
    func mapCollectionViewCellDidTapInfoOnAnnotation(_ vc: MapCollectionViewCell, post: LinkModel, owner: String) {
        let vc = PostLinkViewController(post: post, owner: owner)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
    
}

