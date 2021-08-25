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
    
    private var  stackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
//        stack.layer.cornerRadius = 17.5
        return stack
    }()

 
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        collectionView?.delegate = self
        collectionView?.dataSource = self
        configureCollectionView()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeRight.direction = .right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
        

    }
    
    //MARK: - Init
    

    
    //MARK: - LayoutSubviews

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height)
    }

    //MARK: - ConfigureNavigationBar
    
    private func configureNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "LINK"
        titleLabel.textColor = UIColor.black
        titleLabel.font = .systemFont(ofSize: 30, weight: .semibold)
        let leftItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
        
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "paperplane.fill"), style: .done, target: self, action: #selector(didTapMessage)),
            UIBarButtonItem(image: UIImage(systemName: "mappin.and.ellipse"), style: .done, target: self, action: #selector(didTapLocation)),
            UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21)), style: .done, target: self, action: #selector(didTapAdd))]
    }
  
    //MARK: - BarButtonactions
    
    @objc func didTapMessage() {
        tabBarController?.tabBar.isHidden = true
        let vc = ConversationsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapAdd() {
        tabBarController?.tabBar.isHidden = true
        let vc = LinkCameraViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func didTapLocation() {
        
    }

    
    //MARK: - SwipeAction

    
    @objc func didSwipeRight() {
        print("Print swipe right")
        tabBarController?.tabBar.isHidden = true
        let vc = LinkCameraViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didSwipeLeft() {
        print("Print swipe left")
//        let vc = LinkNotificationViewController()
//        navigationController?.pushViewController(vc, animated: true)
        
        guard let user = UserDefaults.standard.string(forKey: "username"), let email = UserDefaults.standard.string(forKey: "email") else {return}
        
        tabBarController?.tabBar.isHidden = true
        let vc = ProfileViewController(user: User(username: user, email: email))
        navigationController?.pushViewController(vc, animated: true)
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
                        heightDimension: .fractionalHeight(1)),
                    subitem: mapItem,
                    count: 1
                )

                // Section
                let section = NSCollectionLayoutSection(group: group)

                if index == 0 {
                    section.boundarySupplementaryItems = [
                        NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: NSCollectionLayoutSize(
                                widthDimension: .fractionalWidth(1),
                                heightDimension: .fractionalWidth(0.28)
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
    
    func homeMapViewContainerDidTapExplore(_ container: HomeMapViewContainer) {
        let vc = ExploreViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func homeMapViewContainerDidTapPinLocation(_ container: HomeMapViewContainer) {
        // pin something on the map!
    }
    
    
    func homeMapViewContainerDidTapProfile(_ container: HomeMapViewContainer) {
        
        guard let user = UserDefaults.standard.string(forKey: "username"), let email = UserDefaults.standard.string(forKey: "email") else {return}
        
        let vc = ProfileViewController(user: User(username: user, email: email))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func homeMapViewContainerDidTapMessages(_ container: HomeMapViewContainer) {
        let vc = ConversationsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func homeMapViewContainerDidTapNotifications(_ container: HomeMapViewContainer) {
        let vc = NotificationsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
        


}

extension MapViewController: MapCollectionViewCellDelegate {
    func mapCollectionViewCellDidTapInfoOnAnnotation(_ vc: MapCollectionViewCell, post: LinkModel, owner: String) {
        let vc = PostLinkViewController(link: post, owner: owner)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
    }
    
    
}

