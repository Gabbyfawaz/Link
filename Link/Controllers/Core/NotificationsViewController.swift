//
//  NotificationsViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

/// View Controller to show user notifications
final class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var viewModels: [NotificationCellType] = []
    private var models: [LinkNotification] = []

    private let noActivityLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.isHidden = true
        table.register(
            LikeNotificationTableViewCell.self,
            forCellReuseIdentifier: LikeNotificationTableViewCell.identifer
        )
        table.register(
            CommentNotificationTableViewCell.self,
            forCellReuseIdentifier: CommentNotificationTableViewCell.identifer
        )
        table.register(
            FollowNotificationTableViewCell.self,
            forCellReuseIdentifier: FollowNotificationTableViewCell.identifer
        )
        
        table.register(AcceptNotificationTableCell.self, forCellReuseIdentifier: AcceptNotificationTableCell.identifer)
        
        table.register(RequestNotificationTableViewCell.self, forCellReuseIdentifier: RequestNotificationTableViewCell.identifer)
        
        table.register(AcceptedNotificationTableViewCell.self, forCellReuseIdentifier: AcceptedNotificationTableViewCell.identifer)
        
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Notifications"
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(noActivityLabel)
        fetchNotifications()
        configureNavBar()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didTapRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
       
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }

    private func fetchNotifications() {
        NotificationsManager.shared.getNotifications {[weak self] models in
            DispatchQueue.main.async {
                self?.models = models
                self?.createViewModels()
                print("the models: \(models)")
                
            }
        }
        
        
        
        
    }
    
    /// configure Navigation Bar

    private func configureNavBar() {
        let titleLabel = UILabel()
        titleLabel.text = "NOTIFICATIONS"
        titleLabel.textColor = UIColor.label
        titleLabel.font = .systemFont(ofSize: 30, weight: .semibold)
        let leftItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.leftBarButtonItems = [ UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(didTapRight)), leftItem]
        view.backgroundColor = .systemBackground
        tabBarController?.tabBar.isHidden = true
//        navigationItem.backButtonDisplayMode = .minimal
    }
    
    @objc private func didTapRight() {
        navigationController?.popViewController(animated: true )
        tabBarController?.tabBar.isHidden = false
    }
    
    
    /// Creates viewModels from models
    private func createViewModels() {
    
        
        models.forEach { model in
            guard let type = NotificationsManager.linkType(rawValue: model.notificationType) else {
                return
            }
        
            let username = model.username
          
            
            switch type {
            case .like:
                
                guard let postUrl = URL(string: model.postUrl) else {
                    return
                }
                
            
                viewModels.append(
                    .like(
                        viewModel: LikeNotificationCellViewModel(
                            username: username,
//                            profilePictureUrl: profilePictureUrl,
                            postUrl: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .comment:
                guard let postUrl = URL(string: model.postUrl) else {
                    return
                }
                
                viewModels.append(
                    .comment(
                        viewModel: CommentNotificationCellViewModel(
                            username: username,
//                            profilePictureUrl: profilePictureUrl,
                            postUrl: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .follow:
                DatabaseManager.shared.isFollowing(targetUsername: model.username) { isFollowing in
                    print("isFollowing: \(isFollowing)")
                    
                        let buttonType: FollowNotificationButtonType = .follow(isFollowing: isFollowing)
                        
                        self.viewModels.append(
                            .follow(
                                viewModel: FollowNotificationCellViewModel(
                                    id: model.identifer,
                                    username: username,
                                    isCurrentUserFollowing: isFollowing,
                                    date: model.dateString,
                                    buttonType: buttonType
                                )
                            )
                        )
                }
               
                        
            case .accept:
               let isAccepted = model.isRequesting[0] ?? false
                guard let postUrl = URL(string: model.postUrl) else {
                    return
                }
                
                guard let postId = model.postId else {
                    return
                }
                
//                guard let linkIconPictureURL = URL(string: model.username) else {
//                    return
//                }
                
                viewModels.append(
                    .accept(
                        viewModel: AcceptNotificationCellViewModel(
                            username: username,
//                            linkIconPictureUrl: profilePictureUrl,
                            isCurrentInGuestInvited: isAccepted,
                            postUrl: postUrl,
                            date: model.dateString,
                            postId: postId)
                    )
                )
            case .request:
                let isRequested = model.isRequesting[0] ?? false
                
                guard let postUrl = URL(string: model.postUrl) else {
                    return
                }
                
                guard let postId = model.postId else {
                    return
                }

//                guard let linkIconPictureURL = URL(string: model.postLinkIconImage) else {
//                    return
//                }
                
                viewModels.append(
                    .request(
                        viewModel: RequestNotificationCellViewModel(
                            id: model.identifer,
                            username: username,
//                            linkIconPictureUrl: profilePictureUrl,
                            isRequested: isRequested,
                            postUrl: postUrl,
                            date: model.dateString,
                            postId: postId)
                    )
                )
            case .accepetedRequest:
                guard let postUrl = URL(string: model.postUrl) else {
                    return
                }
                
                guard let postId = model.postId else {
                    return
                }
                
//                guard let linkIconPictureURL = URL(string: model.postLinkIconImage) else {
//                    return
//                }
                
                viewModels.append(
                    .acceptedRequest(
                        viewModel: AcceptedRequestNotificationCellViewModel(
                            username: username,
//                            linkIconPictureUrl: profilePictureUrl,
                            isCurrentInGuestInvited: false,
                            postUrl: postUrl,
                            date: model.dateString,
                            postId: postId)
                    )
                )
            }
        }

        if viewModels.isEmpty {
            noActivityLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noActivityLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    
    // MARK: - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModels[indexPath.row]
        switch cellType {
        case .follow(let viewModel):
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FollowNotificationTableViewCell.identifer,
                for: indexPath
            ) as? FollowNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .like(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LikeNotificationTableViewCell.identifer,
                for: indexPath
            ) as? LikeNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .comment(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CommentNotificationTableViewCell.identifer,
                for: indexPath
            ) as? CommentNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .accept(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: AcceptNotificationTableCell.identifer,
                for: indexPath
            ) as? AcceptNotificationTableCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
            
        case .request(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: RequestNotificationTableViewCell.identifer,
                for: indexPath
            ) as? RequestNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
            
        case .acceptedRequest(let viewModel):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: AcceptedNotificationTableViewCell.identifer,
                for: indexPath
            ) as? AcceptedNotificationTableViewCell else {
                fatalError()
            }
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellType = viewModels[indexPath.row]
        var linkId: String = ""
        let username: String
        switch cellType {
        case .follow(let viewModel):
            username = viewModel.username
        case .like(let viewModel):
            username = viewModel.username
        case .comment(let viewModel):
            username = viewModel.username
        case .accept(viewModel: let viewModel):
            username = viewModel.username
            linkId = viewModel.postId
        case .request(viewModel: let viewModel):
            username = viewModel.username
            linkId = viewModel.postId
        case .acceptedRequest(viewModel: let viewModel):
            username = viewModel.username
            linkId = viewModel.postId
        }
        
        
        DatabaseManager.shared.getLink(with: linkId, from: username) { [weak self] linkModel in
            
            guard let linkModel = linkModel else {
                return
            }
            DispatchQueue.main.async {
              let vc = EventViewController(link: linkModel, owner: username)
                vc.modalPresentationStyle = .automatic
                self?.present(vc, animated: true, completion: nil)
            }
        }
            
  
        

        DatabaseManager.shared.findUser(username: username) { [weak self] user in
            guard let user = user else {
                // Show error alert
                return
            }

            DispatchQueue.main.async {
                let vc = ProfileViewController(user: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - Actions

extension NotificationsViewController: LikeNotificationTableViewCellDelegate, CommentNotificationTableViewCellDelegate, FollowNotificationTableViewCellDelegate, RequestNotificationTableViewCellDelegate, AcceptNotificationTableCellDelegate, AcceptedNotificationTableViewCellDelegate
{
    func acceptNotificationTableCell(_ cell: AcceptNotificationTableCell, didTapButton isAccepted: Bool, viewModel: AcceptNotificationCellViewModel) {
        //
    }
    
   
    func acceptedNotificationTableViewCell(_ cell: AcceptedNotificationTableViewCell, didTapPostWith viewModel: AcceptedRequestNotificationCellViewModel) {
        // do something when post is tapped!
    }
    

    func requestNotificationTableViewCell(_ cell: RequestNotificationTableViewCell, didTapButton isRequest: Bool, viewModel: RequestNotificationCellViewModel) {
        
        // remove the user who requested from requested database
        print("the isRequest:\(isRequest)")
        DatabaseManager.shared.updateRequestState(state: viewModel.isRequested ? .requesting: .request, postID: viewModel.postId, owner: viewModel.username) { isSuccess in
            if isSuccess {
                DatabaseManager.shared.updateAcceptState(state: viewModel.isRequested ? .accepted : .accept, postID: viewModel.postId, owner: viewModel.username) { isSuccess in
                    if isSuccess {
                       
                        DatabaseManager.shared.updateNotifticationRequestButton(owner: viewModel.username, notificationID: viewModel.id, isAccepted: isRequest) { isSuccess in
                            if isSuccess {
                                
                                let userRequesting = viewModel.username
                                let id = NotificationsManager.newIdentifier()
                        //        let linkIconString = viewModel.linkIconPictureUrl.absoluteString
                                let linkPost = viewModel.postUrl.absoluteString
                                guard let username = UserDefaults.standard.string(forKey: "username") else {
                                    return
                                }
                                
                                let acceptedRequest = LinkNotification(identifer: id, notificationType: 6, username: username, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: [nil], isRequesting: [nil], postId: viewModel.postId, postUrl: linkPost )
                                
                                
                                NotificationsManager.shared.create(notification: acceptedRequest, for: userRequesting)
                            }
                        }
                       
                 
                        }
                    }
                }
            }
        // add to newUserArray
        // send a notification to person who made request
        
     
    
    }
    
   
    
    
    
    func likeNotificationTableViewCell(_ cell: LikeNotificationTableViewCell,
                                       didTapPostWith viewModel: LikeNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .comment, .follow, .accept, .request, .acceptedRequest:
                return false
            case .like(let current):
                return current == viewModel
            }
        }) else {
            return
        }

        openPost(with: index, username: viewModel.username)
    }

    func commentNotificationTableViewCell(_ cell: CommentNotificationTableViewCell,
                                          didTapPostWith viewModel: CommentNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .like, .follow, .accept, .request, .acceptedRequest:
                return false
            case .comment(let current):
                return current == viewModel
            }
        }) else {
            return
        }

        openPost(with: index, username: viewModel.username)
    }

    func followNotificationTableViewCell(
        _ cell: FollowNotificationTableViewCell,
        didTapButton isFollowing: Bool,
        viewModel: FollowNotificationCellViewModel
    ) {
        
        print("the following button is: \(isFollowing)")
        let username = viewModel.username
        DatabaseManager.shared.updateRelationship(
            state: isFollowing ? .unfollow : .follow,
            for: username
        ) { [weak self] isSuccess in
            if isSuccess {
                
                guard let username = UserDefaults.standard.string(forKey: "username") else {
                    return
                }
                DatabaseManager.shared.updateNotifticationFollowButton(owner: username, notificationID: viewModel.id, isFollowing: isFollowing) { isSuccess in
                    
                    if isFollowing {
                        
                        let id = NotificationsManager.newIdentifier()
                        guard let username = UserDefaults.standard.string(forKey: "username") else {
                            return
                        }
                        
                        let followNotification = LinkNotification(identifer: id, notificationType: 3, username: username, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: [isFollowing], isRequesting: [nil],  postId: "", postUrl: "")
                        
                    
                        
                        NotificationsManager.shared.create(notification: followNotification, for: viewModel.username)
                }
                }
                       
                } else {
                       DispatchQueue.main.async {
                           let alert = UIAlertController(
                               title: "Woops",
                               message: "Unable to perform action.",
                               preferredStyle: .alert
                           )
                           alert.addAction(
                               UIAlertAction(
                                   title: "Dismiss",
                                   style: .cancel,
                                   handler: nil
                               )
                           )
                           self?.present(alert, animated: true)
                       }
                   }
        }
    }

    func openPost(with index: Int, username: String) {
        guard index < models.count else {
            return
        }

        let model = models[index]
        let username = username
        guard let postID = model.postId else {
            return
        }

        // Find post by id from target user
        DatabaseManager.shared.getLink(
            with: postID,
            from: username
        ) { [weak self] link in
            DispatchQueue.main.async {
                guard let link = link else {
                    let alert = UIAlertController(
                        title: "Oops",
                        message: "We are unable to open this post.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self?.present(alert, animated: true)
                    return
                }

                let vc = EventViewController(link: link, owner: username)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    
}

