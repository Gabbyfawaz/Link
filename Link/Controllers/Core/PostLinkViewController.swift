//
//  PostLinkViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import Appirater
import SDWebImage
import CoreLocation

class PostLinkViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
 

    private let linkModel: LinkModel
    
    private let owner: String
    
    private var estimatedHeight: CGFloat?

    private var collectionView: UICollectionView?
    
    private var postStrings = [String]()
    
    private var commentModel = [Comment]()
    
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

    private let customLocationView = CustomLocationPopUp()
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
       
        
        fetchPost()
//        observeKeyboardChange()
         Appirater.tryToShowPrompt()
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didTapRight))

        swipeRight.direction = .right
        
        view.addGestureRecognizer(swipeRight)
        
        
        
        
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
    
    
    @objc func didTapRight() {
        
    }

//    private func observeKeyboardChange() {
//        observer = NotificationCenter.default.addObserver(
//            forName: UIResponder.keyboardWillChangeFrameNotification,
//            object: nil,
//            queue: .main
//        ) { notification in
//            guard let userInfo = notification.userInfo,
//                  let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
//                return
//            }
//            UIView.animate(withDuration: 0.2) {
//                self.commentBarView.frame = CGRect(
//                    x: 0,
//                    y: self.view.height-60-height,
//                    width: self.view.width,
//                    height: 70
//                )
//            }
//        }
//
//        hideObserver = NotificationCenter.default.addObserver(
//            forName: UIResponder.keyboardWillHideNotification,
//            object: nil,
//            queue: .main
//        ) { _ in
//            UIView.animate(withDuration: 0.2) {
//                self.commentBarView.frame = CGRect(
//                    x: 0,
//                    y: self.view.height-self.view.safeAreaInsets.bottom-70,
//                    width: self.view.width,
//                    height: 70
//                )
//            }
//        }
//    }

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
            DatabaseManager.shared.getComments(postID: model.id, owner: model.user) { commentModel in
                let commentModelCount = commentModel.count
    //            print("Number of comments: \(commentModelCount)")
         
            self?.postStrings = model.postArrayString
            let isLiked = model.likers.contains(currentUsername)

//            DatabaseManager.shared.getComments(
//                postID: strongSelf.linkModel.id,
//                owner: strongSelf.owner
//            ) { comments in
//
            
//            self?.mainImageView.sd_setImage(with: postUrl, completed: nil)
            
            let postLinkData: [SingleLinkPostCellViewModelType] = [
                
                .post(viewModel: PostLinkCollectionViewCellViewModel(postString: model.postArrayString, user: model.user)),
                .poster(viewModel: PosterLinkCollectionViewCellViewModel(linkType: model.linkTypeName, profilePictureURL: profileLinkTypeImage, userArray: model.invites)),
                .actions(viewModel: PostLinkActionCollectionViewCellViewModel(isLiked: isLiked, likers: model.likers, comments: "\(commentModelCount)", dateOfLink: model.linkDate)),
                .info(viewModel: PostLinkExtraInfoCollectionCellViewModel(extraInfomation: model.extraInformation, username: model.user)),
//                .extraInfo(viewModel: PostLinkExtraInfoCollectionCellViewModel(extraInfomation: model.extraInformation, username: model.user)),
                .invite(viewModel: PostInviteCollectionViewCellViewModel(invites: model.invites)),
                .location(viewModel: PostLocationCollectionViewCellViewModel(location: model.locationTitle, isPrivate: model.isPrivate, coordinates: model.location, user: model.user, postLinkIcon: model.linkTypeImage)),
//                .date(viewModel: PostLinkDateCollectionCellViewModel(dateString: model.linkDate))
                .logistic(viewModel: PostLogisticCollectionViewCellViewModel(date: model.linkDate))
//
            ]
            
            
                strongSelf.viewModels = postLinkData
                completion(true)
            }
        }
    }


    
    func numberOfComments() -> String {
        var numberOfComments = 0
        
        print("Number of comments: \(numberOfComments)")
        return "\(numberOfComments)"
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
                cell.delegate = self
                cell.configure(with: viewModel)
                return cell
            case .post(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PostLinkCollectionViewCell.identifier,
                    for: indexPath
                ) as? PostLinkCollectionViewCell else {
                    fatalError()
                }
                cell.delegate = self
                cell.configure(with: viewModel, index: indexPath.section)
                return cell
            case .actions(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PostLinkActionCollectionViewCell.identifier,
                    for: indexPath
                ) as? PostLinkActionCollectionViewCell else {
                    fatalError()
                }

                cell.delegate = self
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
                cell.delegate = self
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
//            case .date(viewModel: let viewModel):
//                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostLinkDateCollectionViewCell.identifier,
//                for: indexPath
//            ) as? PostLinkDateCollectionViewCell else {
//                fatalError()
//            }
//    //                cell.delegate = self
//            cell.configure(with: viewModel)
//            return cell
            }
        }
        

}


//MARK: - PosterDelegates - Request Button

extension PostLinkViewController: PosterLinkCollectionViewCellDelegate {
   
    func posterLinkCollectionViewCellDidTapAccept(_ cell: PosterLinkCollectionViewCell, index: Int, isAccepted: Bool) {
      
       let targetUser = linkModel.user
        let linkID = linkModel.id
        let postLinkIconImage = linkModel.linkTypeImage
        let postImage = linkModel.postArrayString[0]
        DatabaseManager.shared.updateGuestList(state: .accepted, linkId: linkID, eventUsername: targetUser) { success in
            if success {
                let id = NotificationsManager.newIdentifier()
                
       
                
                let acceptModel = LinkNotification(identifer: id, notificationType: 6, profilePictureUrl: targetUser, postLinkIconImage: postLinkIconImage, username: targetUser, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: nil, isAccepted: nil, postId: linkID, postUrl: postImage)
                
                NotificationsManager.shared.create(notification: acceptModel, for: targetUser)
            } else {
                print("Trouble in paradise")
            }
        }
        
        
        
    }
    
    func posterLinkCollectionViewCellDidTapRequest(_ cell: PosterLinkCollectionViewCell, index: Int, isRequested: Bool) {
        
        DatabaseManager.shared.updateRelationshipRequest(
            state: .requesting
        ) { [weak self] success in
            
            if !success {
                
                print("failed to follow")
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                    
                }
            } else {
                /// send accept notification to user
                let id = NotificationsManager.newIdentifier()
                
                
                guard let user = UserDefaults.standard.string(forKey: "username") else {
                    return
                }
                
                guard let postLinkIconImage = self?.linkModel.linkTypeImage else {
                    return
                }
                
                guard let postImage = self?.linkModel.postArrayString[0] else {
                    return
                }
                
                guard let postId = self?.linkModel.id else {
                    return
                }
                
                
                let acceptModel = LinkNotification(identifer: id, notificationType: 5, profilePictureUrl: user, postLinkIconImage: postLinkIconImage, username: user, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: nil, isAccepted: nil, postId: postId, postUrl: postImage)
                
                NotificationsManager.shared.create(notification: acceptModel, for: user)
            }
        }
    }
    
    
}


extension PostLinkViewController: PostLinkCollectionViewCellDelegate {
    
    func postCollectionViewCellDidLike(_ cell: PostLinkCollectionViewCell, index: Int) {
        DatabaseManager.shared.updateLikeState(
            state: .like,
            postID: linkModel.id,
            owner: owner
        ) { success in
            
            let id = NotificationsManager.newIdentifier()
            if success {
                let likeNotification = LinkNotification(identifer: id, notificationType: 1, profilePictureUrl: "", postLinkIconImage: "", username: self.linkModel.user, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: false, isAccepted: false, postId: self.linkModel.id, postUrl: self.linkModel.postArrayString[0])
            
                NotificationsManager.shared.create(notification: likeNotification, for: self.linkModel.user)
        
            } else {
                print("Failed to like")
            }
          
        }
    }
    
    func postLinkCollectionViewCell(_ cell: PostLinkCollectionViewCell, index: Int) {
        let sheet = UIAlertController(
                  title: "Post Actions",
                  message: nil,
                  preferredStyle: .actionSheet
              )
              sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
              sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: { [weak self]  _ in
                  DispatchQueue.main.async {
                      let cellType = self?.viewModels[index]
                      switch cellType {
                      case .post(let viewModel):
                          let vc = UIActivityViewController(
                            activityItems: ["Check out this cool post!", viewModel.postString],
                              applicationActivities: []
                          )
                          self?.present(vc, animated: true)
      
                      default:
                          break
                      }
                  }
              }))
              sheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { _ in
                  // Report post
              }))
              present(sheet, animated: true)
    }
    
    
}

extension PostLinkViewController: CommentBarViewDelegate {
    func commentBarViewDidTapDone(_ commentBarView: CommentBarViewController, withText text: String) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        DatabaseManager.shared.createComments(
            comment: Comment(
                username: currentUsername,
                comment: text,
                dateString: String.date(from: Date()) ?? ""
            ),
            postID: linkModel.id,
            owner: owner
        ) { success in
            DispatchQueue.main.async {
                let id = NotificationsManager.newIdentifier()
                guard let username = UserDefaults.standard.string(forKey: "username") else {
                    return
                }
                if success {
                    let commentNotification = LinkNotification(identifer: id, notificationType: 2, profilePictureUrl: self.linkModel.user, postLinkIconImage: "", username: username , dateString: DateFormatter.formatter.string(from: Date()), isFollowing: false, isAccepted: false, postId: self.linkModel.id, postUrl: self.linkModel.postArrayString[0])
                    NotificationsManager.shared.create(notification: commentNotification, for: self.linkModel.user)
                }
            }
        }
    }
}
//


extension PostLinkViewController: PostLinkActionsCollectionViewCellDelegate {
    
    func postLinkLikesCollectionViewCellDidTapLikeViewComments(_ cell: PostLinkActionCollectionViewCell, index: Int) {
        DatabaseManager.shared.getComments(postID: linkModel.id, owner: owner) { (commentModel) in
          
            print("id: \(self.linkModel.id), owner: \(self.owner)")
            print("Comments: \(commentModel)")
            let vc = CommentBarViewController(commentModel: commentModel)
            vc.modalPresentationStyle = .automatic
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)

        }

    }
    
    func postLinkActionsCollectionViewCellDidTapLike(_ cell: PostLinkActionCollectionViewCell, isLiked: Bool, index: Int) {
        
                DatabaseManager.shared.updateLikeState(
                    state: isLiked ? .like : .unlike,
                    postID: linkModel.id,
                    owner: owner
                ) { success in
                    let id = NotificationsManager.newIdentifier()
                    if success {
                        let likeNotification = LinkNotification(identifer: id, notificationType: 1, profilePictureUrl: "", postLinkIconImage: "", username: self.linkModel.user, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: false, isAccepted: false, postId: self.linkModel.id, postUrl: self.linkModel.postArrayString[0])
                    
                        NotificationsManager.shared.create(notification: likeNotification, for: self.linkModel.user)
                        
                    }
                    print("Failed to like")
                }
    }
    
    func postLinkActionsCollectionViewCellDidTapComment(_ cell: PostLinkActionCollectionViewCell, index: Int) {
        
        DatabaseManager.shared.getComments(postID: linkModel.id, owner: owner) { (commentModel) in
          
            print("id: \(self.linkModel.id), owner: \(self.owner)")
            print("Comments: \(commentModel)")
            let vc = CommentBarViewController(commentModel: commentModel)
            vc.modalPresentationStyle = .automatic
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)

        }
//        commentBarView.field.becomeFirstResponder()
    }
    
    func postLinkLikesCollectionViewCellDidTapLikeCount(_ cell: PostLinkActionCollectionViewCell, index: Int) {
        let vc = ListViewController(type: .likers(usernames: linkModel.likers))
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true, completion: nil)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}



extension PostLinkViewController: PostInfoCollectionViewCellDelegate {
    func posterCollectionViewCellDidTapUsername(_ cell: PostInfoCollectionViewCell, index: Int) {
        DatabaseManager.shared.findUser(username: owner) { [weak self] user in
            DispatchQueue.main.async {
                guard let user = user else {
                    return
                }
                let vc = ProfileViewController(user: user)
                let navVC = UINavigationController(rootViewController: vc)
                self?.present(navVC, animated: true, completion: nil)

            }
        }
    }
    
    
}


extension PostLinkViewController: PostInviteCollectionViewCellDelegate {
    
    func postInviteCollectionViewCell(_ cell: PostInviteCollectionViewCell, username: String) {
        // first find user
        
      
        DatabaseManager.shared.findUser(username: username) { user in
            guard let user = user else {
                return
            }
         
            DispatchQueue.main.async {
                    let vc = ProfileViewController(user: user)
                    let navVC = UINavigationController(rootViewController: vc)
                    self.present(navVC, animated: true, completion: nil)

            }
        
        }
    }
    
    
}

extension PostLinkViewController {
    private func configureCollectionView() {
        
        let sectionHeight: CGFloat =  665  + view.width
        
        // mark add 150 if adding back extra info
            let collectionView = UICollectionView(
                frame: .zero,
                collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in

                    
//                    guard let estimateHeight = self.estimatedHeight else {fatalError()}
                    // Group
                    
                  
                    let postItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(1)

                        )
                    )
                    
                    let posterItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(60)
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
                            heightDimension: .absolute(100+30)
                        )
                    )

                    let locationItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(100+170)
                        )
                    )

                    let logisticItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(40)
                        )
                    )
                    
                    
//                    let dateItem = NSCollectionLayoutItem(
//                        layoutSize: NSCollectionLayoutSize(
//                            widthDimension: .fractionalWidth(1),
//                            heightDimension: .absolute(70)
//                        )
//                    )

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
//                            dateItem,
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




