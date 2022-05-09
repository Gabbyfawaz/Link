//
//  LinkNotificationViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import UberRides
import CoreLocation
import MapKit

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating, SearchResultsLinkViewControllerDelegate {

    
    //MARK: - Properties
    
    private var searchVC = UISearchController(searchResultsController: SearchResultsLinkViewController())

    
    /// Feed viewModels
    private var linkPostViewModels = [[SingleLinkFeedCellViewModelType]]()
    /// Notification observer
    private var observer: NSObjectProtocol?
    /// All post models
    private var allLinks: [(link: LinkModel, owner: String)] = []
    
    private var LinkPostCollectionView: UICollectionView?
    
//    private var isRequested = false
    private var action = NameOfLinkCollectionCellViewActions.request(isRequested: false)
    
        // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
        override func viewDidLoad() {
            super.viewDidLoad()
            configureNavBar()
            configureCollectionView()
            fetchLinkPosts()
            observer = NotificationCenter.default.addObserver(
                forName: .didPostLinkNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.linkPostViewModels.removeAll()
                self?.fetchLinkPosts()
                print("we back babbbby!")
            }
        }
    
    //MARK: - ConfigureUI
    
    private func configureNavBar() {

        let titleLabel = UILabel()
        titleLabel.text = "FEED"
        titleLabel.textColor = UIColor.label
        titleLabel.font = .systemFont(ofSize: 30, weight: .semibold)
        let leftItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
        navigationController?.navigationBar.tintColor = .label
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItems = [
        UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: #selector(didTapProfile)),
        UIBarButtonItem(image: UIImage(systemName: "suit.heart"), style: .done, target: self, action: #selector(didTapNotifications)),
        UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .done, target: self, action: #selector(didTapExplore))
        ]
        
        (searchVC.searchResultsController as? SearchResultsLinkViewController)?.delegate = self
        searchVC.searchBar.placeholder = "Search..."
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
    }
    
    private func configureCollectionView() {
        let LinkPostCollectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 20
            layout.itemSize = CGSize(width: view.width-30, height: 250)
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .systemBackground
            collectionView.showsHorizontalScrollIndicator = false
            
            collectionView.register(PostFeedCollectionViewCell.self,
                                            forCellWithReuseIdentifier: PostFeedCollectionViewCell.identifier)
            return collectionView
        }()

        self.LinkPostCollectionView = LinkPostCollectionView
        view.addSubview(LinkPostCollectionView)
        LinkPostCollectionView.delegate = self
        LinkPostCollectionView.dataSource = self

    }
    
        //MARK: - LayoutSubviews
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
    
            LinkPostCollectionView?.frame = view.bounds
        }
    
    //MARK: ACTIONS
    
    @objc private func didTapProfile() {
        
        guard let username = UserDefaults.standard.string(forKey: "username"), let email = UserDefaults.standard.string(forKey: "email") else {
            fatalError("could not get username and email")
        }
        
        let user = User(username: username, email: email)
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true )
    }
    
    @objc private func didTapExplore() {
        let vc = ExploreViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapNotifications() {
        let vc = NotificationsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
     
        //MARK: - FetchPosts for All links
    
        private func fetchLinkPosts() {
            // mock data
            guard let username = UserDefaults.standard.string(forKey: "username") else {
                return
            }
            let userGroup = DispatchGroup()
            userGroup.enter()
    
            var allLinks: [(link: LinkModel, owner: String)] = []
    
            DatabaseManager.shared.following(for: username) { usernames in
                defer {
                    userGroup.leave()
                }
    
                let users = usernames + [username]
                for current in users {
                    userGroup.enter()
                    DatabaseManager.shared.getAllLinks(for: current) { result in
                        DispatchQueue.main.async {
                            defer {
                                userGroup.leave()
                            }
//
                            switch result {
                            case .success(let links):
                                allLinks.append(contentsOf: links.compactMap({
                                    (link: $0, owner: current)
                                }))
    
                            case .failure:
                                break
                            }
                        }
                    }
                }
            }
            
            userGroup.notify(queue: .main) {
                let group = DispatchGroup()
                self.allLinks = allLinks
                print("allLinks: \(allLinks)")
                allLinks.forEach { model in
                    group.enter()
                    self.createLinkPostViewModel(
                        model: model.link,
                        username: model.owner,
                        completion: { success in
                            defer {
                                group.leave()
                            }
                            if !success {
                                print("failed to create VM")
                            }
                        }
                    )
                }
    
                group.notify(queue: .main) {
                    self.LinkPostCollectionView?.reloadData()
                }
            }
        }
    
         
      //MARK: - Create Model
    
    
        private func createLinkPostViewModel(
            model: LinkModel,
            username: String,
            completion: @escaping (Bool) -> Void
        ) {
      
            guard let username = UserDefaults.standard.string(forKey: "username") else {
                return
            }
            let user = SearchUser(name: username)
            let isPending = model.pending.contains(user)
            let isAccepted = model.accepted.contains(user)
            let isRequested = model.requesting.contains(user)
           
            var button = NameOfLinkCollectionCellViewActions.request(isRequested: false)
            if isPending {
                button = .accept(isAccepted: false)
            } else {
                if isAccepted {
                    button = .accept(isAccepted: isAccepted)
                } else {
                    button = .request(isRequested: isRequested)
                }
            }
            guard let profileLinkTypeImage = URL(string: model.linkTypeImage) else {
              return
            }
            
            let postStringArray = model.postArrayString

           
           
//            DatabaseManager.shared.isRequestEvent(targetUsername: username, linkId: model.id) { isRequested in
//
//                print("isRequested in linkNotification is: \(isRequested)")
////                self.isRequested = isRequested
//                button = .request(isRequested: isRequested)
//                print("The button is: \(isRequested)")
                
               
//                DatabaseManager.shared.getPendingUsers(targetUser: username, linkId: model.id) { pending  in
//
//                    DatabaseManager.shared.getAcceptedUsers(targetUser: username, linkId: model.id) { confirmed in
                        let postLinkData: [SingleLinkFeedCellViewModelType] = [
                            
                            .nameOfLink(viewModel: PostOfFeedCollectionViewModel(
                                linkId: model.id,
                                linkType: model.linkTypeName,
                                linkTypeImage: profileLinkTypeImage,
                                mainImage: postStringArray,
                                username: model.user,
                                locationTitle: model.locationTitle,
                                pendingUsers: model.pending,
                                confirmedUsers: model.accepted,
                                isPrivate: model.isPrivate,
                                coordinates: model.location,
                                date: model.linkDate,
                                actionButton: button))

                        ]
                        
                            print("Link Type Name: \(model.linkTypeName)")
                            self.linkPostViewModels.append(postLinkData)
                            completion(true)

//                    }
//
//                }
//            }
            
        
               
            
        }
    

        //MARK: - CollectionViewDataSource/Delegate
    
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return linkPostViewModels.count
            }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return linkPostViewModels[section].count
        }
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cellLinkType = linkPostViewModels[indexPath.section][indexPath.row]
            switch cellLinkType {
            case .nameOfLink(viewModel: let viewModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostFeedCollectionViewCell.identifier, for: indexPath) as? PostFeedCollectionViewCell else {fatalError()}
                cell.configure(with: viewModel)
                cell.nameOfLinkView.delegate = self
                cell.inviteOfLinkView.delegate = self
                cell.locationOfLinkView.delegate = self
                return cell
            }
            
        }
    
    

    
    //MARK: - Delegate Functions
    
    func updateSearchResults(for searchController: UISearchController) {
        
               guard let resultsVC = searchController.searchResultsController as? SearchResultsLinkViewController,
                     let query = searchController.searchBar.text,
                     !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                   return
               }

               DatabaseManager.shared.findLinks(with: query) { results in
                print("Results: \(results)")
                
                resultsVC.update(with: results)
//                   DispatchQueue.main.async {
//                       resultsVC.update(with: results)
//                   }
    }
    }
    
    func searchResultsViewController(_ vc: SearchResultsLinkViewController, didSelectResultWith links: LinkModel) {
        let vc = EventViewController(link: links, owner: links.user)
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true, completion: nil)
    }
    
    
    
    
}


extension FeedViewController: NameofLinkCollectionViewDelegate {
    
    func nameofLinkCollectionViewDidDoubleTapImage(_view: NameofLinkCollectionView, linkId: String, username: String) {
        DatabaseManager.shared.updateLikeState(state: .like, postID: linkId, owner: username) { success in
            if success {
                print("Sucessfully updated like status to the database!")
            }
        }
    }
    
    func nameofLinkCollectionViewDidTapImage(_view: NameofLinkCollectionView, linkId: String, username: String) {
        
        let group = DispatchGroup()
        var userLink: LinkModel?
        group.enter()
        allLinks.forEach { link in
            if link.link.id == linkId {
                defer {
                    group.leave()
                }
                userLink = link.link
            }
        }
        group.notify(queue: .main) {
            guard let userLink = userLink else {
                return
            }
            let vc = EventViewController(link: userLink, owner: username)
            vc.modalPresentationStyle = .automatic
            self.present(vc, animated: true)
            print("Did tap Image!")
        }
    
    }
    
    ///Name container: Did Tap Image
   
    
}

extension FeedViewController: InvitesCollectionViewDelegate {
    
    func invitesCollectionViewDelegateDidTapRequest(_ view: InvitesCollectionView, linkId: String, username: String, isRequesting: Bool) {
        
        DatabaseManager.shared.updateRequestState(state: isRequesting ? .requesting : .request, postID: linkId, owner: username) { success in
            if success {
                // send out a notification
            }
        }
       
//        DatabaseManager.shared.updateRelationshipRequest(linkId: linkId, username: username, state: isRequesting ? .requesting : .request) { isRequested in
//
//            print("isRequested is: \(isRequested)")
////            self.isRequested = isRequested
//        }
    }
    
    func invitesCollectionViewDelegateDidTapAccept(_ view: InvitesCollectionView, linkId: String, username: String, isAccepted: Bool) {
        print("Did tap Accepted")
        
        DatabaseManager.shared.updateAcceptState(state: isAccepted ? .accepted : .accept, postID: linkId, owner: username) { success in
            if success {
                // send out a notification
            }
        }
    }
    

    
    
}

extension FeedViewController: LocationViewContainerDelegate {
    
    func locationViewContainerDidTapAppleMaps(_ view: LocationViewContainer, options: [String : NSValue], mapItem: MKMapItem) {
        
        let alert = UIAlertController(title: "Open Maps?", message: "This action will open Maps", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { _ in
            mapItem.openInMaps(launchOptions: options)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
       
        present(alert, animated: true)
      
    }
    
    
 
    
    func locationViewContainerDidTapUber(_ view: LocationViewContainer, deepLink: RequestDeeplink) {
        print("Did Tap Uber")
        let alert = UIAlertController(title: "Open Uber?", message: "This action will open Uber", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { _ in
            deepLink.execute()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alert, animated: true)
    }
    
    
}
