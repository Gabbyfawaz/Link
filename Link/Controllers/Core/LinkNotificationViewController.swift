//
//  LinkNotificationViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

class LinkNotificationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - Properties

    private let LinkPostCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 400, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(NameofLinkCollectionViewCell.self,
                                forCellWithReuseIdentifier: NameofLinkCollectionViewCell.identifier)
        collectionView.register(PostLocationCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostLocationCollectionViewCell.identifier)
        collectionView.register(PostInviteCollectionViewCell.self,
                                forCellWithReuseIdentifier: PostInviteCollectionViewCell.identifier)
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
            title = "LINK"
            
            view.backgroundColor = .systemBackground
    
            navigationController?.navigationBar.prefersLargeTitles = true

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
    
    
                let postLinkData: [SingleLinkFeedCellViewModelType] = [
                    .nameOfLink(viewModel: NameOfCollectionViewViewModel(linkType: model.linkTypeName, linkTypeImage: profileLinkTypeImage, username: model.user)),
                    .location(viewModel: PostLocationCollectionViewCellViewModel(location: model.locationTitle, isPrivate: model.isPrivate)),
                    .invites(viewModel: PostInviteCollectionViewCellViewModel(invites: model.invites))
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
            case .nameOfLink(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NameofLinkCollectionViewCell.identifier, for: indexPath) as? NameofLinkCollectionViewCell else {fatalError()}
                cell.configure(with: viewModel, index: indexPath.section)
                return cell
            case .location(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostLocationCollectionViewCell.identifier, for: indexPath) as? PostLocationCollectionViewCell else {fatalError()}
                cell.configure(with: viewModel, index: indexPath.section)
                return cell
            case .invites(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostInviteCollectionViewCell.identifier, for: indexPath) as? PostInviteCollectionViewCell else {fatalError()}
                cell.configure(with: viewModel)
                return cell
            }
            
        }
    
}
