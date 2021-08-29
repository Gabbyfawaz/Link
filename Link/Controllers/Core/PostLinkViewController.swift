//
//  PostLinkViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import Appirater
import SDWebImage

class PostLinkViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let linkModel: LinkModel
    
    private let owner: String
    
    private var estimatedHeight: CGFloat?

    private var collectionView: UICollectionView?
    
    private var postStrings = [String]()
    
    private var mainImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    
    
    private var iconImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()

    private var viewModels: [SingleLinkPostCellViewModelType] = []

//    private let commentBarView = CommentBarView()

    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?

    // MARK: - Init

    init(
        link: LinkModel,
        owner: String
    ) {
        self.owner = owner
        self.linkModel = link
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        view.addSubview(mainImageView)
        view.addSubview(iconImageView)
//        view.addSubview(imageCollectionView)
//        view.addSubview(commentBarView)
//        commentBarView.delegate = self
        fetchPost()
        observeKeyboardChange()
         Appirater.tryToShowPrompt()
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didTapRight))

        swipeRight.direction = .right
        
        view.addGestureRecognizer(swipeRight)
        
    }
    
    
    @objc func didTapRight() {
        
        
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        mainImageView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.width)
//        iconImageView.frame = CGRect(x: 15, y: 15, width: 50, height: 50)
    
        collectionView?.frame = view.bounds
        
//        commentBarView.frame = CGRect(
//            x: 0,
//            y: view.height-view.safeAreaInsets.bottom-70,
//            width: view.width,
//            height: 70
//        )
    }

    private func observeKeyboardChange() {
        observer = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
                return
            }
//            UIView.animate(withDuration: 0.2) {
//                self.commentBarView.frame = CGRect(
//                    x: 0,
//                    y: self.view.height-60-height,
//                    width: self.view.width,
//                    height: 70
//                )
//            }
        }

        hideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
//            UIView.animate(withDuration: 0.2) {
//                self.commentBarView.frame = CGRect(
//                    x: 0,
//                    y: self.view.height-self.view.safeAreaInsets.bottom-70,
//                    width: self.view.width,
//                    height: 70
//                )
//            }
        }
    }

    private func fetchPost() {
        // mock data
        let username = owner
        DatabaseManager.shared.getLink(with: linkModel.id, from: username) { [weak self] linkPost in
            guard let linkPost = linkPost else {
                return
            }

            self?.createViewModel(
                model: linkPost,
                username: username,
                completion: { success in
                    guard success else {
                        return
                    }

                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
            )
        }
    }
    
    
    

    private func createViewModel(
        model: LinkModel,
        username: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        StorageManager.shared.profilePictureURL(for: username) { [weak self] profilePictureURL in
            guard let strongSelf = self,
//                  let profilePhotoUrl = profilePictureURL,
                  let profileLinkTypeImage = URL(string: model.linkTypeImage) else {
                completion(false)
                return
            }
            
         
            self?.postStrings = model.postArrayString
            let isLiked = model.likers.contains(currentUsername)

//            DatabaseManager.shared.getComments(
//                postID: strongSelf.post.id,
//                owner: strongSelf.owner
//            ) { comments in
            
            
//            self?.mainImageView.sd_setImage(with: postUrl, completed: nil)
            
            
            let postLinkData: [SingleLinkPostCellViewModelType] = [
                
                .post(viewModel: PostLinkCollectionViewCellViewModel(postString: model.postArrayString, user: model.user)),
                .poster(viewModel: PosterLinkCollectionViewCellViewModel(linkType: model.linkTypeName, profilePictureURL: profileLinkTypeImage)),
                .actions(viewModel: PostLinkActionCollectionViewCellViewModel(isLiked: isLiked, likers: model.likers)),
                .info(viewModel: PostLinkExtraInfoCollectionCellViewModel(extraInfomation: model.extraInformation, username: model.user)),
//                .extraInfo(viewModel: PostLinkExtraInfoCollectionCellViewModel(extraInfomation: model.extraInformation, username: model.user)),
                .invite(viewModel: PostInviteCollectionViewCellViewModel(invites: model.invites)),
                .location(viewModel: PostLocationCollectionViewCellViewModel(location: model.locationTitle, isPrivate: model.isPrivate, coordinates: model.location, user: model.user)),
                .date(viewModel: PostLinkDateCollectionCellViewModel(dateString: model.linkDate)),
                .logistic(viewModel: PostLogisticCollectionViewCellViewModel(date: model.date))
              
            ]
            
            
                strongSelf.viewModels = postLinkData
                completion(true)
            }
//        }
    }


    
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

            return viewModels.count

       
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        

            
            let cellType = viewModels[indexPath.row]
            switch cellType {
            case .poster(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PosterLinkCollectionViewCell.identifier,
                    for: indexPath
                ) as? PosterLinkCollectionViewCell else {
                    fatalError()
                }
    //            cell.delegate = self
                cell.configure(with: viewModel)
                return cell
            case .post(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PostLinkCollectionViewCell.identifier,
                    for: indexPath
                ) as? PostLinkCollectionViewCell else {
                    fatalError()
                }
    //            cell.delegate = self
                cell.configure(with: viewModel, index: indexPath.section)
                return cell
            case .actions(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PostLinkActionCollectionViewCell.identifier,
                    for: indexPath
                ) as? PostLinkActionCollectionViewCell else {
                    fatalError()
                }

    //            cell.delegate = self
                cell.configure(with: viewModel, index: indexPath.section)
                return cell
            case .info(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PostInfoCollectionViewCell.identifier,
                    for: indexPath
                ) as? PostInfoCollectionViewCell else {
                    fatalError()
                }
                cell.delegate = self
                cell.configure(with: viewModel, index: indexPath.section)
                return cell
            case .invite(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PostInviteCollectionViewCell.identifier,
                    for: indexPath
                ) as? PostInviteCollectionViewCell else {
                    fatalError()
                }
    //            cell.delegate = self
                cell.configure(with: viewModel)
                return cell
            case .location(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PostLocationCollectionViewCell.identifier,
                    for: indexPath
                ) as? PostLocationCollectionViewCell else {
                    fatalError()
                }
    //                cell.delegate = self
                cell.configure(with: viewModel)
                return cell
            case .logistic(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PostLogisticCollectionViewCell.identifier,
                    for: indexPath
                ) as? PostLogisticCollectionViewCell else {
                    fatalError()
                }
    //                cell.delegate = self
                cell.configure(with: viewModel)
                return cell
    //            case .extraInfo(viewModel: let viewModel):
    //                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostLinkExtraInfoCollectionViewCell.identifier,
    //                for: indexPath
    //            ) as? PostLinkExtraInfoCollectionViewCell else {
    //                fatalError()
    //            }
    ////                cell.delegate = self
    //            cell.configure(with: viewModel)
    //            return cell
            case .date(viewModel: let viewModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostLinkDateCollectionViewCell.identifier,
                for: indexPath
            ) as? PostLinkDateCollectionViewCell else {
                fatalError()
            }
    //                cell.delegate = self
            cell.configure(with: viewModel)
            return cell
            }
        }
        

}

//extension PostLinkViewController: CommentBarViewDelegate {
//    func commentBarViewDidTapDone(_ commentBarView: CommentBarView, withText text: String) {
//        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
//        DatabaseManager.shared.createComments(
//            comment: Comment(
//                username: currentUsername,
//                comment: text,
//                dateString: String.date(from: Date()) ?? ""
//            ),
//            postID: post.id,
//            owner: owner
//        ) { success in
//            DispatchQueue.main.async {
//                guard success else {
//                    return
//                }
//            }
//        }
//    }
//}
//
//extension PostLinkViewController: PostLikesCollectionViewCellDelegate {
//    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell, index: Int) {
//        let vc = ListViewController(type: .likers(usernames: []))
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}
//
//extension PostLinkViewController: PostCaptionCollectionViewCellDelegate {
//    func postCaptionCollectionViewCellDidTapCaptioon(_ cell: PostCaptionCollectionViewCell) {
//        print("tapped caption")
//    }
//}
//
//extension PostLinkViewController: PostActionsCollectionViewCellDelegate {
//
//    
//    func postLikesCollectionViewCellDidTapLikeCount(_ cell: PostActionsCollectionViewCell, index: Int) {
//        let vc = ListViewController(type: .likers(usernames: []))
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    
//    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell, index: Int) {
//        let cellType = viewModels[index]
//        switch cellType {
//        case .post(let viewModel):
//            let vc = UIActivityViewController(
//                activityItems: ["Check out this cool post!", viewModel.postUrl],
//                applicationActivities: []
//            )
//            present(vc, animated: true)
//
//        default:
//            break
//        }
//    }
//
//    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {
////        commentBarView.field.becomeFirstResponder()
//    }
//
//    func postActionsCollectionViewCellDidTapLike(
//        _ cell: PostActionsCollectionViewCell,
//        isLiked: Bool,
//        index: Int) {
////        DatabaseManager.shared.updateLikeState(
////            state: isLiked ? .like : .unlike,
////            postID: post.id,
////            owner: owner
////        ) { success in
////            guard success else {
////                return
////            }
////            print("Failed to like")
////        }
//    }
//}
//
//extension PostLinkViewController: PostCollectionViewCellDelegate {
//    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
////        DatabaseManager.shared.updateLikeState(
////            state: .like,
////            postID: post.id,
////            owner: owner
////        ) { success in
////            guard success else {
////                return
////            }
////            print("Failed to like")
////        }
//    }
//}
//
//extension PostLinkViewController: PosterCollectionViewCellDelegate {
//    func posterCollectionViewCellDidTapMore(_ cell: PosterCollectionViewCell, index: Int) {
//        let sheet = UIAlertController(
//            title: "Post Actions",
//            message: nil,
//            preferredStyle: .actionSheet
//        )
//        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: { [weak self]  _ in
//            DispatchQueue.main.async {
//                let cellType = self?.viewModels[index]
//                switch cellType {
//                case .post(let viewModel):
//                    let vc = UIActivityViewController(
//                        activityItems: ["Check out this cool post!", viewModel.postUrl],
//                        applicationActivities: []
//                    )
//                    self?.present(vc, animated: true)
//
//                default:
//                    break
//                }
//            }
//        }))
//        sheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { _ in
//            // Report post
//        }))
//        present(sheet, animated: true)
//    }
//
//    func posterCollectionViewCellDidTapUsername(_ cell: PosterCollectionViewCell, index: Int) {
//        DatabaseManager.shared.findUser(username: owner) { [weak self] user in
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

extension PostLinkViewController {
    private func configureCollectionView() {
        
        let sectionHeight: CGFloat =  775 + 30 + view.width
        
        // mark add 150 if adding back extra info
            let collectionView = UICollectionView(
                frame: .zero,
                collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in

                    
//                    guard let estimateHeight = self.estimatedHeight else {fatalError()}
                    // Group
                    
                  
                    let postItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(self.view.width)

                        )
                    )
                    
                    let posterItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(40)
                        )
                    )


                    let actionsItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(65)
                        )
                    )
                    
                    
                    let infoItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(100)
                        )
                        )
//
//                    let extraInfomationItem = NSCollectionLayoutItem(
//                        layoutSize: NSCollectionLayoutSize(
//                            widthDimension: .fractionalWidth(1),
//                            heightDimension: .absolute(170)
//                        )
//                    )
                    
                    let inviteItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(100+50+50)
                        )
                    )

                    let locationItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(100+160)
                        )
                    )

                    let logisticItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(40)
                        )
                    )
                    
                    
                    let dateItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(70+30)
                        )
                    )

                    let group = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(sectionHeight)
                        ),
                        subitems: [
                            postItem,
                            posterItem,
                            actionsItem,
                            infoItem,
//                            extraInfomationItem,
                            inviteItem,
                            locationItem,
                            dateItem,
                            logisticItem
                        ]
                    )

                    // Section
                    let section = NSCollectionLayoutSection(group: group)

//                    if index == 0 {
//                        section.boundarySupplementaryItems = [
//                            NSCollectionLayoutBoundarySupplementaryItem(
//                                layoutSize: NSCollectionLayoutSize(
//                                    widthDimension: .fractionalWidth(1),
//                                    heightDimension: .fractionalWidth(0.3)
//                                ),
//                                elementKind: UICollectionView.elementKindSectionHeader,
//                                alignment: .top
//                            )
//                        ]
//                    }

                    section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)
                    return section
                })
            )

        view.insertSubview(collectionView, at: 1)
        collectionView.isScrollEnabled = true
        collectionView.layer.masksToBounds = true
        collectionView.layer.cornerRadius = 20
        
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumInteritemSpacing = view.width
//        layout.minimumLineSpacing = 0
//        collectionView.collectionViewLayout = layout
            collectionView.backgroundColor = .systemBackground
            collectionView.delegate = self
            collectionView.dataSource = self

            collectionView.register(
                PosterLinkCollectionViewCell.self,
                forCellWithReuseIdentifier: PosterLinkCollectionViewCell.identifier
            )
            collectionView.register(
                PostLinkCollectionViewCell.self,
                forCellWithReuseIdentifier: PostLinkCollectionViewCell.identifier
            )
            collectionView.register(
                PostLinkActionCollectionViewCell.self,
                forCellWithReuseIdentifier: PostLinkActionCollectionViewCell.identifier
            )
            collectionView.register(
                PostInfoCollectionViewCell.self,
                forCellWithReuseIdentifier: PostInfoCollectionViewCell.identifier
            )
        
            collectionView.register(
                PostLocationCollectionViewCell.self,
                forCellWithReuseIdentifier: PostLocationCollectionViewCell.identifier
            )
        collectionView.register(
            PostInviteCollectionViewCell.self,
            forCellWithReuseIdentifier: PostInviteCollectionViewCell.identifier
        )
            collectionView.register(
                PostLogisticCollectionViewCell.self,
                forCellWithReuseIdentifier: PostLogisticCollectionViewCell.identifier
            )
        
        collectionView.register(
            PostLinkExtraInfoCollectionViewCell.self,
            forCellWithReuseIdentifier: PostLinkExtraInfoCollectionViewCell.identifier
        )
        
        collectionView.register(
            PostLinkDateCollectionViewCell.self,
            forCellWithReuseIdentifier: PostLinkDateCollectionViewCell.identifier
        )


//            collectionView.register(
//                StoryHeaderView.self,
//                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                withReuseIdentifier: StoryHeaderView.identifier
//            )

            self.collectionView = collectionView
        
    }
    
}



extension PostLinkViewController: PostInfoCollectionViewCellDelegate{
    func postInfoCollectionViewCellHeight(_ cell: PostInfoCollectionViewCell, size: CGFloat) {
        print("size: \(size)")
        self.estimatedHeight = size
    }
    
    func postInfoCollectionViewCellDidTapInfo(_ cell: PostInfoCollectionViewCell) {
        //
    }
    

    
    
}
