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
import UberRides
import MapKit


//protocol PostLinkViewControllerDelegate: AnyObject {
//    func updateLikerState(_ vc: PostLinkViewController, likers: [String] )
//}
class EventViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
 
    private let buttonTicket: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 27.5
        button.setTitle("Get Ticket", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.shadowColor = UIColor.white.cgColor
        button.layer.shadowRadius = 3.0
        button.layer.shadowOpacity = 1.0
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        return button
    }()
    
    weak var myCollectionViewHeight: NSLayoutConstraint?
    
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

    private var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private var viewModels: [SingleLinkPostCellViewModelType] = []
//    private var action: NameOfLinkCollectionCellViewActions = .request(isRequested: false)

//    private let commentBarView = CommentBarView()

    private let customLocationView = CustomLocationPopUp()
    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?
    private var isRequested = false
    private var isAccepted  = false
    

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
        view.addSubview(buttonTicket)
       
        
        fetchPost()
//        observeKeyboardChange()
         Appirater.tryToShowPrompt()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didTapRight))
        swipeRight.direction = .left
        
        collectionView?.addGestureRecognizer(swipeRight)
        
        
    }
    
  

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    
        collectionView?.frame = view.bounds
//        buttonTicket.frame = CGRect(x: (view.width-140)/2, y: view.height-100, width: 140, height: 55)
    
    }
    
    
    @objc func didTapRight() {
        
        // swipe right
        
        print("This is the old vc")
        if let vcs = self.navigationController?.viewControllers {
            let previousVC = vcs[vcs.count - 2]
            if previousVC is ProfileViewController {
               print("This is the old vc1")
            }
        }
        
    }
    
    
    private func sendNotification() {
       
    }


    private func fetchPost() {
        // mock data
        let username = owner
//        let group = DispatchGroup()
        print("The user's post: \(username)")
    
        var button: NameOfLinkCollectionCellViewActions = .accept(isAccepted:  false)

        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        let user = SearchUser(name: currentUsername)
        DatabaseManager.shared.getLink(with: linkModel.id, from: username) { [weak self] linkPost in

          
            guard let linkPost = linkPost else {
                return
            }
            
            
            let isPending = linkPost.pending.contains(user)
            let isAccepted = linkPost.accepted.contains(user)
            let isRequesting = linkPost.requesting.contains(user)
            
            if isPending {
                button = .accept(isAccepted: false)
            } else {
                if isAccepted {
                    button = .accept(isAccepted: isAccepted)
                } else {
                    button = .request(isRequested: isRequesting)
                }
            }
            
            
            self?.createViewModel(model: linkPost,username: username,button: button, completion: { success in
                    guard success else {
                        return
                    }

                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
            )
            
        }
            
//            DatabaseManager.shared.isPending(targetUsername: username, linkId: linkPost.id) { isPending in
//                var button: NameOfLinkCollectionCellViewActions = .accept(isAccepted:  false)
//                if isPending {
//                    button = .accept(isAccepted: false)
//                    self?.createViewModel(model: linkPost,username: username,button: button, completion: { success in
//                            guard success else {
//                                return
//                            }
//
//                            DispatchQueue.main.async {
//                                self?.collectionView?.reloadData()
//                            }
//                        }
//                    )
//                } else {
//                    DatabaseManager.shared.isAccepted(targetUsername: username, linkId: linkPost.id) { isAccepted in
//                        if isAccepted {
//                            button = .accept(isAccepted: isAccepted)
//                            self?.createViewModel(model: linkPost,username: username,button: button, completion: { success in
//                                    guard success else {
//                                        return
//                                    }
//
//                                    DispatchQueue.main.async {
//                                        self?.collectionView?.reloadData()
//                                    }
//                                }
//                            )
//
//                        } else {
//                            DatabaseManager.shared.isRequestEvent(targetUsername: username, linkId: linkPost.id) { isRequested in
//                                button = .request(isRequested: isRequested)
//                                self?.createViewModel(model: linkPost,username: username,button: button, completion: { success in
//                                        guard success else {
//                                            return
//                                        }
//
//                                        DispatchQueue.main.async {
//                                            self?.collectionView?.reloadData()
//                                        }
//                                    }
//                                )
//                            }
//                        }
//
//                    }
//                }
//
//            }
//
//
//
//
//            }
//
            
        
    }
    
    
    
    
    private func createViewModel(
        model: LinkModel,
        username: String,
        button: NameOfLinkCollectionCellViewActions,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        
        // confirgure the label quick
        label.sizeToFit()
        label.text = model.info
        StorageManager.shared.profilePictureURL(for: username) { [weak self] profilePictureURL in
            guard let strongSelf = self,
                  //                  let profilePhotoUrl = profilePictureURL,
                  let profileLinkTypeImage = URL(string: model.linkTypeImage) else {
                      completion(false)
                      return
                  }
        
            
            DatabaseManager.shared.getComments(postID: model.id, owner: model.user) { commentModel in
                
                self?.postStrings = model.postArrayString
                let isLiked = model.likers.contains(currentUsername)

//                DatabaseManager.shared.getPendingUsers(targetUser: username, linkId: model.id) { pending  in
//
//                    DatabaseManager.shared.getAcceptedUsers(targetUser: username, linkId: model.id) { confirmed in
                        let postLinkData: [SingleLinkPostCellViewModelType] = [
//
                            
                            .post(viewModel: MediaPostCollectionViewCellViewModel(postString: model.postArrayString, user: model.user)),
                            .poster(viewModel:  NameOfLinkCollectionViewCellViewModel(linkType: model.linkTypeName, profilePictureURL: profileLinkTypeImage, userArray: model.pending, actionButton: button)),
                            .actions(viewModel: PostLinkActionCollectionViewCellViewModel(isLiked: isLiked, likers: model.likers, comments: commentModel, dateOfLink: model.linkDate)),
                            .username(viewModel: PostLinkUsenameCollectionCellViewModel(username: model.user)),
                            .info(viewModel: PostLinkExtraInfoCollectionCellViewModel(username: model.user, extraInfomation: model.extraInformation)),
                            .invite(viewModel: PostInviteCollectionViewCellViewModel(pendingUsers: model.pending, confirmedUsers: model.pending, requesting: model.requesting)),
                            .location(viewModel: PostLocationCollectionViewCellViewModel(location: model.locationTitle, isPrivate: model.isPrivate, coordinates: model.location, user: model.user, postLinkIcon: model.linkTypeImage)),
                            .logistic(viewModel: PostLogisticCollectionViewCellViewModel(date: model.linkDate))
                        ]
                        
                        
                        strongSelf.viewModels = postLinkData
                        completion(true)
//                    }
//
//                }
//
                
                
                
        
            }
        }
    }


    
    func numberOfComments() -> String {
        let numberOfComments = 0
        
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
                    withReuseIdentifier: NameOfLinkCollectionViewCell.identifier,
                    for: indexPath
                ) as? NameOfLinkCollectionViewCell else {
                    fatalError()
                }
                cell.contentView.clipsToBounds = true
                cell.layer.zPosition = CGFloat(indexPath.row)
                cell.delegate = self
                cell.configure(with: viewModel)
                return cell
            case .post(let viewModel):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MediaPostCollectionViewCell.identifier,
                    for: indexPath
                ) as? MediaPostCollectionViewCell else {
                    fatalError()
                }
                cell.delegate = self
                cell.configure(with: viewModel)
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
//                cell.delegate = self
                cell.configure(with: viewModel)
                
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
                cell.delegate = self
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
   
            case .username(viewModel: let viewModel):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PostLinkExtraInfoCollectionViewCell.identifier,
                    for: indexPath
                ) as? PostLinkExtraInfoCollectionViewCell else {
                    fatalError()
                }
                cell.delegate = self
                cell.configure(with: viewModel)
                return cell
            }
        }
        

}


//MARK: - PosterDelegates - Request Button

extension EventViewController: NameOfLinkCollectionViewCellDelegate {
   
    
    
   
    func posterLinkCollectionViewCellDidTapAccept(_ cell: NameOfLinkCollectionViewCell, isAccepted: Bool) {
        
        DatabaseManager.shared.updateAcceptState(
            state: isAccepted ? .accepted : .accept,
            postID: linkModel.id,
            owner: linkModel.user) { success in
                if success {
                    // send notification
                    if !isAccepted {
                        // send notification
                        let id = NotificationsManager.newIdentifier()
    //                    let user = self.linkModel.user
                        guard let user = UserDefaults.standard.string(forKey: "username") else {
                            return
                        }
                        let acceptNoti = LinkNotification(identifer: id, notificationType: 6, username: user, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: [],isRequesting: [], postId: self.linkModel.id, postUrl: self.linkModel.postArrayString[0])
                        //
                        NotificationsManager.shared.create(notification: acceptNoti, for: self.linkModel.user)
        
                    }
                    print("we updated the arrays")
                }
            }

        
        
    }
    
    func posterLinkCollectionViewCellDidTapRequest(_ cell: NameOfLinkCollectionViewCell, isRequested: Bool) {
    
        DatabaseManager.shared.updateRequestState(
            state: isRequested ? .requesting : .request,
            postID: linkModel.id,
            owner: linkModel.user) { success in
                if success {
                    if !isRequested {
                        // send notification
                        let id = NotificationsManager.newIdentifier()
    //                    let user = self.linkModel.user
                        guard let user = UserDefaults.standard.string(forKey: "username") else {
                            return
                        }
                        let requestNoti = LinkNotification(identifer: id, notificationType: 5, username: user, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: [],isRequesting: [isRequested], postId: self.linkModel.id, postUrl: self.linkModel.postArrayString[0])
                        NotificationsManager.shared.create(notification: requestNoti, for: self.linkModel.user)
                        print("we updated the arrays")
                    }
                   
                }
            }
        
        
        
    }
        

    
    
}


extension EventViewController: MediaPostCollectionViewCellDelegate {
    
    func postCollectionViewCellDidLike(_ cell: MediaPostCollectionViewCell, index: Int) {
        DatabaseManager.shared.updateLikeState(
            state: .like,
            postID: linkModel.id,
            owner: owner
        ) { success in
            
            
            let id = NotificationsManager.newIdentifier()
            if success {
                guard let user = UserDefaults.standard.string(forKey: "username") else {
                    return
                }
                let likeNotification = LinkNotification(identifer: id, notificationType: 1, username: user, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: [],isRequesting: [nil], postId: self.linkModel.id, postUrl: self.linkModel.postArrayString[0])
            
                NotificationsManager.shared.create(notification: likeNotification, for: self.linkModel.user)
        
            } else {
                print("Failed to like")
            }
          
        }
    }
    
    func postLinkCollectionViewCell(_ cell: MediaPostCollectionViewCell, index: Int) {
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

extension EventViewController: CommentViewControllerDelegate {
    func commentBarViewDidTapDone(_ commentBarView: CommentViewController, withText text: String) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        DatabaseManager.shared.createComments(
            comment: Comment(
                username: currentUsername,
                comment: text,
                date: Date().timeIntervalSince1970
            ),
            postID: linkModel.id,
            owner: owner
        ) { success in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didUpdateComments, object: self)
                let id = NotificationsManager.newIdentifier()
                guard let username = UserDefaults.standard.string(forKey: "username") else {
                    return
                }
                if success {
                    let commentNotification = LinkNotification(identifer: id, notificationType: 2, username: username , dateString: DateFormatter.formatter.string(from: Date()), isFollowing: [], isRequesting: [],postId: self.linkModel.id, postUrl: self.linkModel.postArrayString[0])
                    NotificationsManager.shared.create(notification: commentNotification, for: self.linkModel.user)
                }
            }
        }
    }
}
//


extension EventViewController: PostLinkActionsCollectionViewCellDelegate {
    
    
    func postLinkActionsCollectionViewCellDidTapLike(_ cell: PostLinkActionCollectionViewCell, isLiked: Bool) {
        
                DatabaseManager.shared.updateLikeState(
                    state: isLiked ? .like : .unlike,
                    postID: linkModel.id,
                    owner: owner
                ) { success in
                    
                   
                    let id = NotificationsManager.newIdentifier()
                    if success {
                        if isLiked {
                            guard let user = UserDefaults.standard.string(forKey: "username") else {
                                return
                            }
                           
    //                        self.delegate?.updateLikerState(self, likers: likers )
                            let likeNotification = LinkNotification(identifer: id, notificationType: 1,username: user, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: [], isRequesting: [nil],  postId: self.linkModel.id, postUrl: self.linkModel.postArrayString[0])
                        
                            NotificationsManager.shared.create(notification: likeNotification, for: self.linkModel.user)
                        }
                        
                        
                    } else {
                        print("Failed to like")
                    }
                }
    }
    
    func postLinkActionsCollectionViewCellDidTapComment(_ cell: PostLinkActionCollectionViewCell, comments: [Comment]) {
        
//        DatabaseManager.shared.getComments(postID: linkModel.id, owner: owner) { (commentModel) in
          
        let vc = CommentViewController(commentModel: comments, linkId: linkModel.id, username: linkModel.user)
            vc.modalPresentationStyle = .automatic
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
//
//        }
//        commentBarView.field.becomeFirstResponder()
    }
    
    func postLinkLikesCollectionViewCellDidTapLikeCount(_ cell: PostLinkActionCollectionViewCell, likers: [String]) {
        let vc = ListViewController(type: .likers(usernames: likers))
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true, completion: nil)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}



//extension PostLinkViewController: PostInfoCollectionViewCellDelegate {
//    func posterCollectionViewCellDidTapUsername(_ cell: PostInfoCollectionViewCell) {
//        DatabaseManager.shared.findUser(username: owner) { [weak self] user in
//            DispatchQueue.main.async {
//                guard let user = user else {
//                    return
//                }
//                let vc = ProfileViewController(user: user)
//                let navVC = UINavigationController(rootViewController: vc)
//                self?.present(navVC, animated: true, completion: nil)
//
//            }
//        }
//    }
//
//
//}


extension EventViewController: PostInviteCollectionViewCellDelegate {
    
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


extension EventViewController: PostLocationCollectionViewCellDelegate {
    
    func postLocationCollectionViewCellDidTapUber(_ cell: PostLocationCollectionViewCell, deepLink: RequestDeeplink) {
        print("Did Tap Uber")
        let alert = UIAlertController(title: "Open Uber?", message: "This action will open Uber", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { _ in
            deepLink.execute()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alert, animated: true)
    }
    
    func postLocationCollectionViewCellDidTapAppleMaps(_ cell: PostLocationCollectionViewCell, options: [String : NSValue], mapItem: MKMapItem) {
        
        let alert = UIAlertController(title: "Open Maps?", message: "This action will open Maps", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { _ in
            mapItem.openInMaps(launchOptions: options)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
       
        present(alert, animated: true)
    }
    
    
}


extension EventViewController: PostLinkExtraInfoCollectionViewCellDelegate {
    func postLinkExtraInfoCollectionViewCellDidTapUsername(_ cell: PostLinkExtraInfoCollectionViewCell) {
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


extension EventViewController {

    private func configureCollectionView() {
        
        var sectionHeight: CGFloat =  705 + view.width
        
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
                            heightDimension: .estimated(60)
                        )
                    )


                    let actionsItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(85)
                        )
                    )
                    

                    let username = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(40)
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
                            heightDimension: .estimated(110)
                        )
                    )

                    let locationItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(270)
                        )
                    )
                    
//                    let logisticItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40)))

                    let logisticItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(40)
                        )
                    )
                    
                    
//                    let dateItem = NSCollectionLayoutItem(
//                        layoutSize: NSCollectionLayoutSize(
//                            widthDimension: .fractionalWidth(1),
//                            heightDimension: .absolute(70)
//                        )
//                    )

                    /// group
                    let group = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(1)
                        ),
                        subitems: [
                            postItem,
                            posterItem,
                            actionsItem,
                            username,
                            infoItem,
//                            extraInfomationItem,
                            inviteItem,
                            locationItem,
//                            dateItem,
                            logisticItem
                        ]
                    )

                    /// Section
                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)
                    return section
                })
            )

        view.insertSubview(collectionView, at: 1)
        collectionView.isScrollEnabled = true
//        collectionView.layer.masksToBounds = true
//        collectionView.layer.cornerRadius = 20
        
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        sectionHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        myCollectionViewHeight?.constant = sectionHeight
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        collectionView.register(
            NameOfLinkCollectionViewCell.self,
            forCellWithReuseIdentifier: NameOfLinkCollectionViewCell.identifier
        )
        collectionView.register(
            MediaPostCollectionViewCell.self,
            forCellWithReuseIdentifier: MediaPostCollectionViewCell.identifier
        )
        collectionView.register(
            PostLinkActionCollectionViewCell.self,
            forCellWithReuseIdentifier: PostLinkActionCollectionViewCell.identifier
        )
        collectionView.register(
            PostLinkExtraInfoCollectionViewCell.self,
            forCellWithReuseIdentifier: PostLinkExtraInfoCollectionViewCell.identifier
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
        
        self.collectionView = collectionView
        
    }
    
}




