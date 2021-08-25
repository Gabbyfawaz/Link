//
//  LinkNotificationViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

class LinkNotificationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating, SearchResultsLinkViewControllerDelegate {

    
    //MARK: - Properties
    
    private var searchVC = UISearchController(searchResultsController: SearchResultsLinkViewController())

    private let LinkPostCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: 400, height: 250)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(PostFeedCollectionViewCell.self,
                                        forCellWithReuseIdentifier: PostFeedCollectionViewCell.identifier)
//        collectionView.register(NameofLinkCollectionViewCell.self,
//                                forCellWithReuseIdentifier: NameofLinkCollectionViewCell.identifier)
//        collectionView.register(PostLocationCollectionViewCell.self,
//                                forCellWithReuseIdentifier: PostLocationCollectionViewCell.identifier)
//        collectionView.register(PostInviteCollectionViewCell.self,
//                                forCellWithReuseIdentifier: PostInviteCollectionViewCell.identifier)
        return collectionView
    }()
    
    
        /// Feed viewModels
        private var linkPostViewModels = [[SingleLinkFeedCellViewModelType]]()
        /// Notification observer
        private var observer: NSObjectProtocol?
        /// All post models
        private var allLinks: [(link: LinkModel, owner: String)] = []
    
    
        // MARK: - Lifecycle
    
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Feed"
            

//            let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
//            navigationController?.navigationBar.titleTextAttributes = textAttributes
            
            (searchVC.searchResultsController as? SearchResultsLinkViewController)?.delegate = self
            searchVC.searchBar.placeholder = "Search..."
            searchVC.searchResultsUpdater = self
            navigationItem.searchController = searchVC
//
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationController?.navigationBar.isHidden = false
            view.backgroundColor = .systemBackground
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            //UIImage.init(named: "transparent.png")
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = .clear
            
            fetchLinkPosts()
            view.addSubview(LinkPostCollectionView)
            LinkPostCollectionView.delegate = self
            LinkPostCollectionView.dataSource = self
    
            observer = NotificationCenter.default.addObserver(
                forName: .didPostLinkNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.linkPostViewModels.removeAll()
                self?.fetchLinkPosts()
            }
        }
    
        //MARK: - LayoutSubviews
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
    
            LinkPostCollectionView.frame = view.bounds
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
                    self.LinkPostCollectionView.reloadData()
                }
            }
        }
    
         
      //MARK: - Create Model
    
    
        private func createLinkPostViewModel(
            model: LinkModel,
            username: String
            ,completion: @escaping (Bool) -> Void
        ) {
            guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
            StorageManager.shared.profilePictureURL(for: username) { [weak self] profilePictureURL in
                guard let postUrl = URL(string: model.postUrlString),
                      let profilePhotoUrl = profilePictureURL,
                      let profileLinkTypeImage = URL(string: model.linkTypeImage) else {
                    return
                }
    
                let isLiked = model.likers.contains(currentUsername)
    
    
                guard let stringDate = String.date(from: model.date) else {return}
                let postLinkData: [SingleLinkFeedCellViewModelType] = [
                    
                    .nameOfLink(viewModel: PostOfFeedCollectionViewModel(
                                    linkType: model.linkTypeName,
                                    linkTypeImage: profileLinkTypeImage,
                                    mainImage: postUrl,
                                    username: model.user,
                                    location: model.locationTitle,
                                    invite: model.invites,
                                    isPrivate: model.isPrivate,
                                    coordinates: model.location,
                                    date: stringDate))
//                    .nameOfLink(viewModel: NameOfCollectionViewViewModel(linkType: model.linkTypeName, linkTypeImage: profileLinkTypeImage, username: model.user)),
//                    .location(viewModel: PostLocationCollectionViewCellViewModel(location: model.locationTitle, isPrivate: model.isPrivate)),
//                    .invites(viewModel: PostInviteCollectionViewCellViewModel(invites: model.invites))
                ]
                
                print("Link Type Name: \(model.linkTypeName)")
                self?.linkPostViewModels.append(postLinkData)
                completion(true)
            }
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
//            case .nameOfLink(let viewModel):
//                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NameofLinkCollectionViewCell.identifier, for: indexPath) as? NameofLinkCollectionViewCell else {fatalError()}
//                cell.configure(with: viewModel, index: indexPath.section)
//                return cell
//            case .location(let viewModel):
//                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostLocationCollectionViewCell.identifier, for: indexPath) as? PostLocationCollectionViewCell else {fatalError()}
//                cell.configure(with: viewModel, index: indexPath.section)
//                return cell
//            case .invites(let viewModel):
//                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostInviteCollectionViewCell.identifier, for: indexPath) as? PostInviteCollectionViewCell else {fatalError()}
//                cell.configure(with: viewModel)
//                return cell
            case .nameOfLink(viewModel: let viewModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostFeedCollectionViewCell.identifier, for: indexPath) as? PostFeedCollectionViewCell else {fatalError()}
                cell.configure(with: viewModel)
                return cell
            }
            
        }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("IndexPath: \(indexPath.section)")
        
        let link = allLinks[indexPath.section].link
        let user = allLinks[indexPath.section].owner
        
        let vc = PostLinkViewController(link: link, owner: user)
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true, completion: nil)
        
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
        let vc = PostLinkViewController(link: links, owner: links.user)
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true, completion: nil)
    }
    
    
    
    
}
