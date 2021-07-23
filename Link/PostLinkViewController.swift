//
//  PostLinkViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import Appirater

class PostLinkViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private let linkModel: LinkModel
    private let owner: String

    private var collectionView: UICollectionView?

    private var viewModels: [SingleLinkPostCellViewModelType] = []

//    private let commentBarView = CommentBarView()

    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?

    // MARK: - Init

    init(
        post: LinkModel,
        owner: String
    ) {
        self.owner = owner
        self.linkModel = post
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
//        view.addSubview(commentBarView)
//        commentBarView.delegate = self
        fetchPost()
        observeKeyboardChange()

        // Appirater.tryToShowPrompt()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
                  let postUrl = URL(string: model.postUrlString),
                  let profilePhotoUrl = profilePictureURL,
                  let profileLinkTypeImage = URL(string: model.linkTypeImage) else {
                completion(false)
                return
            }

            let isLiked = model.likers.contains(currentUsername)

//            DatabaseManager.shared.getComments(
//                postID: strongSelf.post.id,
//                owner: strongSelf.owner
//            ) { comments in
            let postLinkData: [SingleLinkPostCellViewModelType] = [
                
                .poster(viewModel: PosterLinkCollectionViewCellViewModel(linkType: model.linkTypeName, profilePictureURL: profileLinkTypeImage)),
                .post(viewModel: PostLinkCollectionViewCellViewModel(postUrl: postUrl)),
                .actions(viewModel: PostLinkActionCollectionViewCellViewModel(isLiked: isLiked, likers: model.likers)),
                .info(viewModel: PostInfoCollectionViewCellViewModel(username: model.user, info: model.info)),
                .invite(viewModel: PostInviteCollectionViewCellViewModel(invites: model.invites)),
                .location(viewModel: PostLocationCollectionViewCellViewModel(location: model.locationTitle, isPrivate: model.isPrivate)),
                .date(viewModel: PostLinkDateCollectionCellViewModel(dateString: model.postedDate)),
                .extraInfo(viewModel: PostLinkExtraInfoCollectionCellViewModel(extraInfomation: model.extraInformation)),
                .logistic(viewModel: PostLogisticCollectionViewCellViewModel(date: model.date))
              
            ]
                self?.viewModels = postLinkData
                completion(true)
            }
//        }
    }

    // CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = viewModels[indexPath.row]
        switch cellType {
        case .poster(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PosterlinkCollectionViewCell.identifier,
                for: indexPath
            ) as? PosterlinkCollectionViewCell else {
                fatalError()
            }
//            cell.delegate = self
            cell.configure(with: viewModel, index: indexPath.section)
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
//                cell.delegate = self
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
            cell.configure(with: viewModel, index: indexPath.section)
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
            case .extraInfo(viewModel: let viewModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostLinkExtraInfoCollectionViewCell.identifier,
                for: indexPath
            ) as? PostLinkExtraInfoCollectionViewCell else {
                fatalError()
            }
//                cell.delegate = self
            cell.configure(with: viewModel)
            return cell
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
            let sectionHeight: CGFloat = 420 + 150 + 100 + view.width
        
        // mark add 150 if adding back extra info
            let collectionView = UICollectionView(
                frame: .zero,
                collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in

                    // Item
                    let posterItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(80)
                        )
                    )

                    let postItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(1)
                        )
                    )

                    let actionsItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(60)
                        )
                    )

                    let infoItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(60)
                        )
                    )
                    
                    let inviteItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(100)
                        )
                    )

                    let locationItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(80)
                        )
                    )

                    let logisticItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(40)
                        )
                    )
                    
                    let extraInfomationItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(170)
                        )
                    )
                    
                    let dateItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(60)
                        )
                    )

                    // Group
                    let group = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(sectionHeight)
                        ),
                        subitems: [
                            posterItem,
                            postItem,
                            actionsItem,
                            infoItem,
                            inviteItem,
                            locationItem,
                            dateItem,
                            extraInfomationItem,
                            logisticItem,
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

            view.addSubview(collectionView)
        collectionView.isScrollEnabled = true
        
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumInteritemSpacing = view.width
//        layout.minimumLineSpacing = 0
//        collectionView.collectionViewLayout = layout
            collectionView.backgroundColor = .systemBackground
            collectionView.delegate = self
            collectionView.dataSource = self

            collectionView.register(
                PosterlinkCollectionViewCell.self,
                forCellWithReuseIdentifier: PosterlinkCollectionViewCell.identifier
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

