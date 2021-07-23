//
//  HomeViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

//import UIKit
//
///// Home Feed View Controller
//final class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
//
//    /// CollectionView for feed
//    private var postCollectionView: UICollectionView?
//    private var LinkPostCollectionView: UICollectionView?
//
//    /// Feed viewModels
//    private var postViewModels = [[HomeFeedCellType]]()
//    private var linkPostViewModels = [[LinkHomeCellViewModelType]]()
//    
//    /// Notification observer
//    private var observer: NSObjectProtocol?
//
//    /// All post models
//    private var allPosts: [(post: Post, owner: String)] = []
//    private var allLinks: [(link: LinkModel, owner: String)] = []
//    
//    
////    private let scrollView: UIScrollView = {
////        let scrollView = UIScrollView()
////        scrollView.clipsToBounds = true
////        return scrollView
////    }()
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "LINK"
//        navigationController?.navigationBar.isHidden = false
////        view.backgroundColor = .systemBackground
////        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
////        self.navigationController?.navigationBar.shadowImage = UIImage()
////        self.navigationController?.navigationBar.isTranslucent = true
////        self.navigationController?.view.backgroundColor = .clear
//        
//        navigationController?.navigationBar.prefersLargeTitles = true
////        view.addSubview(scrollView)
////        scrollView.isUserInteractionEnabled = true
////        scrollView.contentSize = CGSize(width: (view.width)*2+50, height: (view.height))
//        
//        configureCollectionViewForPost()
//        configureCollectionViewForLinkPost()
//        
//        
//        fetchPosts()
//        fetchLinkPosts()
//
//        observer = NotificationCenter.default.addObserver(
//            forName: .didPostNotification,
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            self?.postViewModels.removeAll()
//            self?.fetchPosts()
//        }
//        
//        observer = NotificationCenter.default.addObserver(
//            forName: .didPostLinkNotification,
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            self?.linkPostViewModels.removeAll()
//            self?.fetchLinkPosts()
//        }
//    }
//
//    //MARK: - LayoutSubviews
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        LinkPostCollectionView?.frame = view.bounds
////        scrollView.frame = view.bounds
////        LinkPostCollectionView?.frame = CGRect(x: 0, y: 0, width: view.width, height: scrollView.height)
////        postCollectionView?.frame = CGRect(x: view.width+50, y: 0, width: view.width, height: scrollView.height)
//    }
//    
//
//    //MARK: - FetchPosts
//    private func fetchPosts() {
//        // mock data
//        guard let username = UserDefaults.standard.string(forKey: "username") else {
//            return
//        }
//        let userGroup = DispatchGroup()
//        userGroup.enter()
//
//        var allPosts: [(post: Post, owner: String)] = []
//
//        DatabaseManager.shared.following(for: username) { usernames in
//            defer {
//                userGroup.leave()
//            }
//
//            let users = usernames + [username]
//            for current in users {
//                userGroup.enter()
//                DatabaseManager.shared.posts(for: current) { result in
//                    DispatchQueue.main.async {
//                        defer {
//                            userGroup.leave()
//                        }
//
//                        switch result {
//                        case .success(let posts):
//                            allPosts.append(contentsOf: posts.compactMap({
//                                (post: $0, owner: current)
//                            }))
//
//                        case .failure:
//                            break
//                        }
//                    }
//                }
//            }
//        }
//
//        userGroup.notify(queue: .main) {
//            let group = DispatchGroup()
//            self.allPosts = allPosts
//            allPosts.forEach { model in
//                group.enter()
//                self.createViewModel(
//                    model: model.post,
//                    username: model.owner,
//                    completion: { success in
//                        defer {
//                            group.leave()
//                        }
//                        if !success {
//                            print("failed to create VM")
//                        }
//                    }
//                )
//            }
//
//            group.notify(queue: .main) {
//                self.sortData()
//                self.postCollectionView?.reloadData()
//            }
//        }
//    }
//
//    // fetch post for link
//    //MARK: - FetchPosts for All links
//    private func fetchLinkPosts() {
//        // mock data
//        guard let username = UserDefaults.standard.string(forKey: "username") else {
//            return
//        }
//        let userGroup = DispatchGroup()
//        userGroup.enter()
//
//        var allLinks: [(link: LinkModel, owner: String)] = []
//
//        DatabaseManager.shared.following(for: username) { usernames in
//            defer {
//                userGroup.leave()
//            }
//
//            let users = usernames + [username]
//            for current in users {
//                userGroup.enter()
//                DatabaseManager.shared.getAllLinks(for: current) { result in
//                    DispatchQueue.main.async {
//                        defer {
//                            userGroup.leave()
//                        }
//
//                        switch result {
//                        case .success(let links):
//                            allLinks.append(contentsOf: links.compactMap({
//                                (link: $0, owner: current)
//                            }))
//
//                        case .failure:
//                            break
//                        }
//                    }
//                }
//            }
//        }
//
//        userGroup.notify(queue: .main) {
//            let group = DispatchGroup()
//            self.allLinks = allLinks
//            print("allLinks: \(allLinks)")
//            allLinks.forEach { model in
//                group.enter()
//                self.createLinkPostViewModel(
//                    model: model.link,
//                    username: model.owner,
//                    completion: { success in
//                        defer {
//                            group.leave()
//                        }
//                        if !success {
//                            print("failed to create VM")
//                        }
//                    }
//                )
//            }
//
//            group.notify(queue: .main) {
//                self.sortData()
//                self.LinkPostCollectionView?.reloadData()
//            }
//        }
//    }
//
//    //MARK: - SortData
//    
//    private func sortData() {
//        allPosts = allPosts.sorted(by: { first, second in
//            let date1 = first.post.date
//            let date2 = second.post.date
//            return date1 > date2
//        })
//
//        postViewModels = postViewModels.sorted(by: { first, second in
//            var date1: Date?
//            var date2: Date?
//            first.forEach { type in
//                switch type {
//                case .timestamp(let vm):
//                    date1 = vm.date
//                default:
//                    break
//                }
//            }
//            second.forEach { type in
//                switch type {
//                case .timestamp(let vm):
//                    date2 = vm.date
//                default:
//                    break
//                }
//            }
//
//            if let date1 = date1, let date2 = date2 {
//                return date1 > date2
//            }
//
//            return false
//        })
//
//    }
//
//    //MARK: - CreateViewModel
//    private func createViewModel(
//        model: Post,
//        username: String,
//        completion: @escaping (Bool) -> Void
//    ) {
//        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
//        StorageManager.shared.profilePictureURL(for: username) { [weak self] profilePictureURL in
//            guard let postUrl = URL(string: model.postUrlString),
//                  let profilePhotoUrl = profilePictureURL else {
//                return
//            }
//
//            let isLiked = model.likers.contains(currentUsername)
//
//            let postData: [HomeFeedCellType] = [
//                .poster(
//                    viewModel: PosterCollectionViewCellViewModel(
//                        username: username,
//                        profilePictureURL: profilePhotoUrl
//                    )
//                ),
//                .post(
//                    viewModel: PostCollectionViewCellViewModel(
//                        postUrl: postUrl
//                    )
//                ),
//                .actions(viewModel: PostActionsCollectionViewCellViewModel(isLiked: isLiked, likers: model.likers)),
//                .caption(
//                    viewModel: PostCaptionCollectionViewCellViewModel(
//                        username: username,
//                        caption: model.caption)),
//                .timestamp(
//                    viewModel: PostDatetimeCollectionViewCellViewModel(
//                        date: DateFormatter.formatter.date(from: model.postedDate) ?? Date()
//                    )
//                )
//            ]
//            self?.postViewModels.append(postData)
//            completion(true)
//        }
//    }
//    
//    
////    MARK: - MockData
//    
//    
//    private func createLinkPostViewModel(
//        model: LinkModel,
//        username: String
//        ,completion: @escaping (Bool) -> Void
//    ) {
//        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
//        StorageManager.shared.profilePictureURL(for: username) { [weak self] profilePictureURL in
//            guard let postUrl = URL(string: model.postUrlString),
//                  let profilePhotoUrl = profilePictureURL,
//                  let profileLinkTypeImage = URL(string: model.linkTypeImage) else {
//                return
//            }
//
//            let isLiked = model.likers.contains(currentUsername)
//
//            
//            let postLinkData: [LinkHomeCellViewModelType] = [
//                
//                .post(viewModel: PostLinkCollectionViewCellViewModel(postUrl: postUrl)),
//                .actions(viewModel: PostLinkActionCollectionViewCellViewModel(isLiked: isLiked, likers: model.likers)),
//                .info(viewModel: PostInfoCollectionViewCellViewModel(username: model.user, info: model.info)),
//                .poster(viewModel: PosterLinkCollectionViewCellViewModel(linkType: model.linkTypeName, profilePictureURL: profileLinkTypeImage)),
//                .invite(viewModel: PostInviteCollectionViewCellViewModel(invites: model.invites)),
////                .location(viewModel: PostLocationCollectionViewCellViewModel(location: model.locationTitle, isPrivate: model.isPrivate)),
////                .extraInfo(viewModel: PostLinkExtraInfoCollectionCellViewModel(extraInfomation: model.extraInformation)),
//                .logistic(viewModel: PostLogisticCollectionViewCellViewModel(date: model.date))
//              
//            ]
//
//
//            print("Link Type Name: \(model.linkTypeName)")
//            self?.linkPostViewModels.append(postLinkData)
//            completion(true)
//        }
//    }
//
//    
//
//    //MARK: - CollectionViewDataSource/Delegate
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        
//        if collectionView == LinkPostCollectionView {
//            return linkPostViewModels.count
//        }
//        return postViewModels.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == LinkPostCollectionView {
//            return linkPostViewModels[section].count
//        }
//        return postViewModels[section].count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        if collectionView == LinkPostCollectionView {
//            let cellLinkType = linkPostViewModels[indexPath.section][indexPath.row]
//            
//            switch cellLinkType {
//            case .poster(let viewModel):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: PosterlinkCollectionViewCell.identifier,
//                    for: indexPath
//                ) as? PosterlinkCollectionViewCell else {
//                    fatalError()
//                }
//                cell.delegate = self
//                cell.configure(with: viewModel, index: indexPath.section)
//                return cell
//            case .post(let viewModel):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: PostLinkCollectionViewCell.identifier,
//                    for: indexPath
//                ) as? PostLinkCollectionViewCell else {
//                    fatalError()
//                }
//    //            cell.delegate = self
//                cell.configure(with: viewModel, index: indexPath.section)
//                return cell
//            case .actions(let viewModel):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: PostLinkActionCollectionViewCell.identifier,
//                    for: indexPath
//                ) as? PostLinkActionCollectionViewCell else {
//                    fatalError()
//                }
//                
//                cell.delegate = self
//                cell.configure(with: viewModel, index: indexPath.section)
//                return cell
//            case .info(let viewModel):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: PostInfoCollectionViewCell.identifier,
//                    for: indexPath
//                ) as? PostInfoCollectionViewCell else {
//                    fatalError()
//                }
////                cell.delegate = self
//                cell.configure(with: viewModel, index: indexPath.section)
//                return cell
//            case .invite(let viewModel):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: PostInviteCollectionViewCell.identifier,
//                    for: indexPath
//                ) as? PostInviteCollectionViewCell else {
//                    fatalError()
//                }
//    //            cell.delegate = self
//                cell.configure(with: viewModel)
//                return cell
////            case .location(let viewModel):
////                guard let cell = collectionView.dequeueReusableCell(
////                    withReuseIdentifier: PostLocationCollectionViewCell.identifier,
////                    for: indexPath
////                ) as? PostLocationCollectionViewCell else {
////                    fatalError()
////                }
//////                cell.delegate = self
////                cell.configure(with: viewModel, index: indexPath.section)
////                return cell
//            case .logistic(let viewModel):
//                guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: PostLogisticCollectionViewCell.identifier,
//                    for: indexPath
//                ) as? PostLogisticCollectionViewCell else {
//                    fatalError()
//                }
////                cell.delegate = self
//                cell.configure(with: viewModel)
//                return cell
////            case .extraInfo(viewModel: let viewModel):
////                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostLinkExtraInfoCollectionViewCell.identifier,
////                for: indexPath
////            ) as? PostLinkExtraInfoCollectionViewCell else {
////                fatalError()
////            }
//////                cell.delegate = self
////            cell.configure(with: viewModel)
////            return cell
//            }
//        }
//        
//        let cellType = postViewModels[indexPath.section][indexPath.row]
//        switch cellType {
//        case .poster(let viewModel):
//            guard let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: PosterCollectionViewCell.identifer,
//                for: indexPath
//            ) as? PosterCollectionViewCell else {
//                fatalError()
//            }
//            cell.delegate = self
//            cell.configure(with: viewModel, index: indexPath.section)
//            return cell
//        case .post(let viewModel):
//            guard let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: PostCollectionViewCell.identifer,
//                for: indexPath
//            ) as? PostCollectionViewCell else {
//                fatalError()
//            }
//            cell.delegate = self
//            cell.configure(with: viewModel, index: indexPath.section)
//            return cell
//        case .actions(let viewModel):
//            guard let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: PostActionsCollectionViewCell.identifer,
//                for: indexPath
//            ) as? PostActionsCollectionViewCell else {
//                fatalError()
//            }
//            cell.delegate = self
//            cell.configure(with: viewModel, index: indexPath.section)
//            return cell
////        case .likeCount(let viewModel):
////            guard let cell = collectionView.dequeueReusableCell(
////                withReuseIdentifier: PostLikesCollectionViewCell.identifer,
////                for: indexPath
////            ) as? PostLikesCollectionViewCell else {
////                fatalError()
////            }
////            cell.delegate = self
////            cell.configure(with: viewModel, index: indexPath.section)
////            return cell
//        case .caption(let viewModel):
//            guard let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: PostCaptionCollectionViewCell.identifer,
//                for: indexPath
//            ) as? PostCaptionCollectionViewCell else {
//                fatalError()
//            }
//            cell.delegate = self
//            cell.configure(with: viewModel)
//            return cell
//        case .timestamp(let viewModel):
//            guard let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: PostDateTimeCollectionViewCell.identifer,
//                for: indexPath
//            ) as? PostDateTimeCollectionViewCell else {
//                fatalError()
//            }
//            cell.configure(with: viewModel)
//            return cell
//        }
//    }
//
////    func collectionView(
////        _ collectionView: UICollectionView,
////        viewForSupplementaryElementOfKind kind: String,
////        at indexPath: IndexPath
////    ) -> UICollectionReusableView {
////        guard kind == UICollectionView.elementKindSectionHeader,
////              let headerView = collectionView.dequeueReusableSupplementaryView(
////                ofKind: kind,
////                withReuseIdentifier: StoryHeaderView.identifier,
////                for: indexPath
////              ) as? StoryHeaderView else {
////            return UICollectionReusableView()
////        }
////        let viewModel = StoriesViewModel(stories: [
////            Story(username: "jeffbezos", image: UIImage(named: "story1")),
////            Story(username: "simon12", image: UIImage(named: "story2")),
////            Story(username: "marqueesb", image: UIImage(named: "story3")),
////            Story(username: "kyliejenner", image: UIImage(named: "story4")),
////            Story(username: "drake", image: UIImage(named: "story5")),
////        ])
////        headerView.configure(with: viewModel)
////        return headerView
////    }
//}
//
////MARK: - CreateingCollectionViewCellForPost
//extension HomeViewController {
//    func configureCollectionViewForPost() {
//        let sectionHeight: CGFloat = 240 + view.width
//        let collectionView = UICollectionView(
//            frame: .zero,
//            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in
//
//                // Item
//                let posterItem = NSCollectionLayoutItem(
//                    layoutSize: NSCollectionLayoutSize(
//                        widthDimension: .fractionalWidth(1),
//                        heightDimension: .absolute(65)
//                    )
//                )
//
//                let postItem = NSCollectionLayoutItem(
//                    layoutSize: NSCollectionLayoutSize(
//                        widthDimension: .fractionalWidth(1),
//                        heightDimension: .fractionalWidth(1)
//                    )
//                )
//
//                let actionsItem = NSCollectionLayoutItem(
//                    layoutSize: NSCollectionLayoutSize(
//                        widthDimension: .fractionalWidth(1),
//                        heightDimension: .absolute(40)
//                    )
//                )
//
//                let likeCountItem = NSCollectionLayoutItem(
//                    layoutSize: NSCollectionLayoutSize(
//                        widthDimension: .fractionalWidth(1),
//                        heightDimension: .absolute(40)
//                    )
//                )
//
//                let captionItem = NSCollectionLayoutItem(
//                    layoutSize: NSCollectionLayoutSize(
//                        widthDimension: .fractionalWidth(1),
//                        heightDimension: .absolute(60)
//                    )
//                )
//
//                let timestampItem = NSCollectionLayoutItem(
//                    layoutSize: NSCollectionLayoutSize(
//                        widthDimension: .fractionalWidth(1),
//                        heightDimension: .absolute(40)
//                    )
//                )
//                
//                
//
//                // Group
//                
//                
//                let group = NSCollectionLayoutGroup.vertical(
//                    layoutSize: NSCollectionLayoutSize(
//                        widthDimension: .fractionalWidth(1),
//                        heightDimension: .absolute(sectionHeight)
//                    ),
//                    subitems: [
//                        posterItem,
//                        postItem,
//                        actionsItem,
//                        likeCountItem,
//                        captionItem,
//                        timestampItem
//                    ]
//                )
//
//                // Section
//                let section = NSCollectionLayoutSection(group: group)
//
////                if index == 0 {
////                    section.boundarySupplementaryItems = [
////                        NSCollectionLayoutBoundarySupplementaryItem(
////                            layoutSize: NSCollectionLayoutSize(
////                                widthDimension: .fractionalWidth(2),
////                                heightDimension: .fractionalWidth(0.3)
////                            ),
////                            elementKind: UICollectionView.elementKindSectionHeader,
////                            alignment: .top
////                        )
////                    ]
////                }
//
//                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)
//
//                return section
//            })
//        )
//
//        view.addSubview(collectionView)
//        collectionView.backgroundColor = .systemBackground
//        collectionView.delegate = self
//        collectionView.dataSource = self
//
//        collectionView.register(
//            PosterCollectionViewCell.self,
//            forCellWithReuseIdentifier: PosterCollectionViewCell.identifer
//        )
//        collectionView.register(
//            PostCollectionViewCell.self,
//            forCellWithReuseIdentifier: PostCollectionViewCell.identifer
//        )
//        collectionView.register(
//            PostActionsCollectionViewCell.self,
//            forCellWithReuseIdentifier: PostActionsCollectionViewCell.identifer
//        )
//        collectionView.register(
//            PostLikesCollectionViewCell.self,
//            forCellWithReuseIdentifier: PostLikesCollectionViewCell.identifer
//        )
//        collectionView.register(
//            PostCaptionCollectionViewCell.self,
//            forCellWithReuseIdentifier: PostCaptionCollectionViewCell.identifer
//        )
//        collectionView.register(
//            PostDateTimeCollectionViewCell.self,
//            forCellWithReuseIdentifier: PostDateTimeCollectionViewCell.identifer
//        )
//
//        collectionView.register(
//            StoryHeaderView.self,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: StoryHeaderView.identifier
//        )
//
//        self.postCollectionView = collectionView
//    }
//}
//
//extension HomeViewController {
//    private func configureCollectionViewForLinkPost() {
//            let sectionHeight: CGFloat = 440 - 80 + view.width
//        
//        // mark add 150 if adding back extra info
//            let collectionView = UICollectionView(
//                frame: .zero,
//                collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in
//
//                    // Item
//                    let posterItem = NSCollectionLayoutItem(
//                        layoutSize: NSCollectionLayoutSize(
//                            widthDimension: .fractionalWidth(1),
//                            heightDimension: .absolute(80)
//                        )
//                    )
//
//                    let postItem = NSCollectionLayoutItem(
//                        layoutSize: NSCollectionLayoutSize(
//                            widthDimension: .fractionalWidth(1),
//                            heightDimension: .fractionalWidth(1)
//                        )
//                    )
//
//                    let actionsItem = NSCollectionLayoutItem(
//                        layoutSize: NSCollectionLayoutSize(
//                            widthDimension: .fractionalWidth(1),
//                            heightDimension: .absolute(60)
//                        )
//                    )
//
//                    let infoItem = NSCollectionLayoutItem(
//                        layoutSize: NSCollectionLayoutSize(
//                            widthDimension: .fractionalWidth(1),
//                            heightDimension: .absolute(60)
//                        )
//                    )
//                    
//                    let inviteItem = NSCollectionLayoutItem(
//                        layoutSize: NSCollectionLayoutSize(
//                            widthDimension: .fractionalWidth(1),
//                            heightDimension: .absolute(100)
//                        )
//                    )
//
////                    let locationItem = NSCollectionLayoutItem(
////                        layoutSize: NSCollectionLayoutSize(
////                            widthDimension: .fractionalWidth(1),
////                            heightDimension: .absolute(80)
////                        )
////                    )
//
//                    let logisticItem = NSCollectionLayoutItem(
//                        layoutSize: NSCollectionLayoutSize(
//                            widthDimension: .fractionalWidth(1),
//                            heightDimension: .absolute(40)
//                        )
//                    )
//                    
////                    let extraInfomationItem = NSCollectionLayoutItem(
////                        layoutSize: NSCollectionLayoutSize(
////                            widthDimension: .fractionalWidth(1),
////                            heightDimension: .absolute(150)
////                        )
////                    )
//
//                    // Group
//                    let group = NSCollectionLayoutGroup.vertical(
//                        layoutSize: NSCollectionLayoutSize(
//                            widthDimension: .fractionalWidth(1),
//                            heightDimension: .absolute(sectionHeight)
//                        ),
//                        subitems: [
//                            postItem,
//                            actionsItem,
//                            infoItem,
//                            posterItem,
//                            inviteItem,
////                            locationItem,
////                            extraInfomationItem,
//                            logisticItem,
//                        ]
//                    )
//
//                    // Section
//                    let section = NSCollectionLayoutSection(group: group)
//
////                    if index == 0 {
////                        section.boundarySupplementaryItems = [
////                            NSCollectionLayoutBoundarySupplementaryItem(
////                                layoutSize: NSCollectionLayoutSize(
////                                    widthDimension: .fractionalWidth(1),
////                                    heightDimension: .fractionalWidth(0.3)
////                                ),
////                                elementKind: UICollectionView.elementKindSectionHeader,
////                                alignment: .top
////                            )
////                        ]
////                    }
//
//                    section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)
//                    return section
//                })
//            )
//
//            view.addSubview(collectionView)
//        collectionView.isScrollEnabled = true
//        
////        let layout = UICollectionViewFlowLayout()
////        layout.scrollDirection = .horizontal
////        layout.minimumInteritemSpacing = view.width
////        layout.minimumLineSpacing = 0
////        collectionView.collectionViewLayout = layout
//            collectionView.backgroundColor = .systemBackground
//            collectionView.delegate = self
//            collectionView.dataSource = self
//
//            collectionView.register(
//                PosterlinkCollectionViewCell.self,
//                forCellWithReuseIdentifier: PosterlinkCollectionViewCell.identifier
//            )
//            collectionView.register(
//                PostLinkCollectionViewCell.self,
//                forCellWithReuseIdentifier: PostLinkCollectionViewCell.identifier
//            )
//            collectionView.register(
//                PostLinkActionCollectionViewCell.self,
//                forCellWithReuseIdentifier: PostLinkActionCollectionViewCell.identifier
//            )
//            collectionView.register(
//                PostInfoCollectionViewCell.self,
//                forCellWithReuseIdentifier: PostInfoCollectionViewCell.identifier
//            )
//        
//            collectionView.register(
//                PostLocationCollectionViewCell.self,
//                forCellWithReuseIdentifier: PostLocationCollectionViewCell.identifier
//            )
//        collectionView.register(
//            PostInviteCollectionViewCell.self,
//            forCellWithReuseIdentifier: PostInviteCollectionViewCell.identifier
//        )
//            collectionView.register(
//                PostLogisticCollectionViewCell.self,
//                forCellWithReuseIdentifier: PostLogisticCollectionViewCell.identifier
//            )
//        
//        collectionView.register(
//            PostLinkExtraInfoCollectionViewCell.self,
//            forCellWithReuseIdentifier: PostLinkExtraInfoCollectionViewCell.identifier
//        )
//
////            collectionView.register(
////                StoryHeaderView.self,
////                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
////                withReuseIdentifier: StoryHeaderView.identifier
////            )
//
//            self.LinkPostCollectionView = collectionView
//        
//    }
//    
//}
//
//
////MARK: - PostDelegates for Post
//extension HomeViewController: PostLikesCollectionViewCellDelegate {
//    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell, index: Int) {
//        HapticManager.shared.vibrateForSelection()
//        let vc = ListViewController(type: .likers(usernames: allPosts[index].post.likers))
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}
//
//extension HomeViewController: PostCaptionCollectionViewCellDelegate {
//    func postCaptionCollectionViewCellDidTapCaptioon(_ cell: PostCaptionCollectionViewCell) {
//        print("tapped caption")
//    }
//}
//
//extension HomeViewController: PostActionsCollectionViewCellDelegate {
//    
//    
//
//    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostActionsCollectionViewCell, index: Int) {
//        HapticManager.shared.vibrateForSelection()
//        let vc = ListViewController(type: .likers(usernames: allPosts[index].post.likers))
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell, index: Int) {
//        AnalyticsManager.shared.logFeedInteraction(.share)
//        let section = postViewModels[index]
//        section.forEach { cellType in
//            switch cellType {
//            case .post(let viewModel):
//                let vc = UIActivityViewController(
//                    activityItems: ["Check out this cool post!", viewModel.postUrl],
//                    applicationActivities: []
//                )
//                present(vc, animated: true)
//
//            default:
//                break
//            }
//        }
//    }
//
//    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {
//        AnalyticsManager.shared.logFeedInteraction(.comment)
//        let tuple = allPosts[index]
//        HapticManager.shared.vibrateForSelection()
//        let vc = PostViewController(post: tuple.post, owner: tuple.owner)
//        vc.title = "Post"
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
//        AnalyticsManager.shared.logFeedInteraction(.like)
//        HapticManager.shared.vibrateForSelection()
//        let tuple = allPosts[index]
//        DatabaseManager.shared.updateLikeState(
//            state: isLiked ? .like : .unlike,
//            postID: tuple.post.id,
//            owner: tuple.owner) { success in
//            guard success else {
//                return
//            }
//            print("Failed to like")
//        }
//    }
//}
//
//extension HomeViewController: PostCollectionViewCellDelegate {
//    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
//        AnalyticsManager.shared.logFeedInteraction(.doubleTapToLike)
//        let tuple = allPosts[index]
//        DatabaseManager.shared.updateLikeState(
//            state: .like,
//            postID: tuple.post.id,
//            owner: tuple.owner) { success in
//            guard success else {
//                return
//            }
//            print("Failed to like")
//        }
//    }
//}
//
//extension HomeViewController: PosterCollectionViewCellDelegate {
//    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, index: Int) {
//        let sheet = UIAlertController(
//            title: "Post Actions",
//            message: nil,
//            preferredStyle: .actionSheet
//        )
//        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: { [weak self]  _ in
//            DispatchQueue.main.async {
//                let section = self?.postViewModels[index] ?? []
//                section.forEach { cellType in
//                    switch cellType {
//                    case .post(let viewModel):
//                        let vc = UIActivityViewController(
//                            activityItems: ["Check out this cool post!", viewModel.postUrl],
//                            applicationActivities: []
//                        )
//                        self?.present(vc, animated: true)
//
//                    default:
//                        break
//                    }
//                }
//            }
//        }))
//        sheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { _ in
//            // Report
//            AnalyticsManager.shared.logFeedInteraction(.reported)
//        }))
//        present(sheet, animated: true)
//    }
//
//    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell, index: Int) {
//        let username = allPosts[index].owner
//        DatabaseManager.shared.findUser(username: username) { [weak self] user in
//            DispatchQueue.main.async {
//                guard let user = user else {
//                    return
//                }
//                let vc = ProfileViewController(user: user)
//                self?.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
//    }
//}
//
//
////MARK: - Extra Delegate functions for Link Post
//
//extension HomeViewController: PosterLinkCollectionViewCellDelegate {
//    func posterLinkCollectionViewCellDidTapRepost(_ cell: PosterlinkCollectionViewCell, index: Int) {
//        let vc = ExploreViewController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    func posterLinkCollectionViewCellDidTapRequest(_ cell: PosterlinkCollectionViewCell, index: Int) {
//        // send the request or acceptance or decline
//    }
//    
//    func posterLinkCollectionViewCellDidTapImageView(_ cell: PosterlinkCollectionViewCell, index: Int) {
//        // move to person's page
////        let vc = ProfileViewController(user: <#T##User#>)
////        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//
//
//}
//
//
//extension HomeViewController: PostLinkActionsCollectionViewCellDelegate {
//    func posterLinkCollectionViewCellDidTapRequest(_ cell: PostLinkActionCollectionViewCell, index: Int) {
//        //
//    }
//    
//    func postLinkActionsCollectionViewCellDidTapLike(_ cell: PostLinkActionCollectionViewCell, isLiked: Bool, index: Int) {
//        AnalyticsManager.shared.logFeedInteraction(.like)
//        HapticManager.shared.vibrateForSelection()
//        let tuple = allPosts[index]
//        DatabaseManager.shared.updateLikeState(
//            state: isLiked ? .like : .unlike,
//            postID: tuple.post.id,
//            owner: tuple.owner) { success in
//            guard success else {
//                return
//            }
//            print("Failed to like")
//        }
//    }
//    
//    func postLinkActionsCollectionViewCellDidTapComment(_ cell: PostLinkActionCollectionViewCell, index: Int) {
//        //
//    }
//    
//    func postLinkActionsCollectionViewCellDidTapMore(_ cell: PostLinkActionCollectionViewCell, index: Int) {
//            let sheet = UIAlertController(
//                title: "Post Actions",
//                message: nil,
//                preferredStyle: .actionSheet
//            )
//            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: { [weak self]  _ in
//                DispatchQueue.main.async {
//                    let section = self?.linkPostViewModels[index] ?? []
//                    section.forEach { cellType in
//                        switch cellType {
//                        case .post(let viewModel):
//                            let vc = UIActivityViewController(
//                                activityItems: ["Check out this cool post!", viewModel.postUrl],
//                                applicationActivities: []
//                            )
//                            self?.present(vc, animated: true)
//
//                        default:
//                            break
//                        }
//                    }
//                }
//            }))
//            sheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { _ in
//                // Report
//    //            AnalyticsManager.shared.logFeedInteraction(.reported)
//            }))
//            present(sheet, animated: true)
//    }
//    
//    func postLinkLikesCollectionViewCellDidTapLikeCount(_ cell: PostLinkActionCollectionViewCell, index: Int) {
//        let vc = ListViewController(type: .likers(usernames: allPosts[index].post.likers))
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    
//    
//}
//
//extension HomeViewController: PostInfoCollectionViewCellDelegate {
//   
//    
//
//    
//    func postInfoCollectionViewCellDidTapInfo(_ cell: PostInfoCollectionViewCell) {
//        
////        let username = allLinks[index].owner
////        DatabaseManager.shared.findUser(username: username) { [weak self] user in
////            DispatchQueue.main.async {
////                guard let user = user else {
////                    return
////                }
////                let vc = ProfileViewController(user: user)
////                self?.navigationController?.pushViewController(vc, animated: true)
////            }
////        }
//
//        // send user to specific profile user
////        let vc = ProfileViewController()
////        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//}
//
//
//extension HomeViewController: PostLocationCollectionViewCellDelegate {
//    func postLocationCollectionViewCellDidTapLocation(_ cell: PostLocationCollectionViewCell, index: Int) {
//        // send the user to link icon on map
//    }
//    
//
//    
//    
//}
//
//
//extension HomeViewController: PostLogisticCollectionViewCellDelegate {
//    func postLogisticCollectionViewCellDidTapLogistics(_ cell: PostLogisticCollectionViewCell) {
//        // drop down to more collection view Controller with invites and declines
//        
//    }
//    
//    
//}
//
//
