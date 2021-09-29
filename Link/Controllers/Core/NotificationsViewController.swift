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
        
        table.register(AcceptedRequestedNotificationTableViewCell.self, forCellReuseIdentifier: AcceptedRequestedNotificationTableViewCell.identifer)
        
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(noActivityLabel)
        fetchNotifications()
        configureNavBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }

    private func fetchNotifications() {
        NotificationsManager.shared.getNotifications { [weak self] models in
            DispatchQueue.main.async {
                self?.models = models
                self?.createViewModels()
            }
        }
    }
    
    /// configure Navigation Bar

    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
    }
    
    /// Creates viewModels from models
    private func createViewModels() {
        
        models.forEach { model in
            guard let type = NotificationsManager.linkType(rawValue: model.notificationType) else {
                return
            }
            let username = model.username
            guard let profilePictureUrl = URL(string: model.profilePictureUrl) else {
                return
            }

            // Derive

            switch type {
            case .like:
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                viewModels.append(
                    .like(
                        viewModel: LikeNotificationCellViewModel(
                            username: username,
                            profilePictureUrl: profilePictureUrl,
                            postUrl: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .comment:
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                viewModels.append(
                    .comment(
                        viewModel: CommentNotificationCellViewModel(
                            username: username,
                            profilePictureUrl: profilePictureUrl,
                            postUrl: postUrl,
                            date: model.dateString
                        )
                    )
                )
            case .follow:
                guard let isFollowing = model.isFollowing else {
                    return
                }
                viewModels.append(
                    .follow(
                        viewModel: FollowNotificationCellViewModel(
                            username: username,
                            profilePictureUrl: profilePictureUrl,
                            isCurrentUserFollowing: isFollowing,
                            date: model.dateString
                        )
                    )
                )
                
            case .accept:
//                guard let isAccepted = model.isAccepted else {
//                    return
//                }
                
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                
                guard let postId = model.postId else {
                    return
                }
                
                guard let linkIconPictureURL = URL(string: model.postLinkIconImage) else {
                    return
                }
                viewModels.append(
                    .accept(
                        viewModel: AcceptNotificationCellViewModel(
                            username: username,
                            linkIconPictureUrl: linkIconPictureURL,
                            isCurrentInGuestInvited: false,
                            postUrl: postUrl,
                            date: model.dateString,
                            postId: postId)
                    )
                )
            case .request:
//                guard let isAccepted = model.isAccepted else {
//                    return
//                }
                
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                
                guard let postId = model.postId else {
                    return
                }
                
                guard let linkIconPictureURL = URL(string: model.postLinkIconImage) else {
                    return
                }
                viewModels.append(
                    .request(
                        viewModel: RequestNotificationCellViewModel(
                            username: username,
                            linkIconPictureUrl: linkIconPictureURL,
                            isRequested: false,
                            postUrl: postUrl,
                            date: model.dateString,
                            postId: postId)
                    )
                )
            case .accepetedRequest:
                guard let postUrl = URL(string: model.postUrl ?? "") else {
                    return
                }
                
                guard let postId = model.postId else {
                    return
                }
                
                guard let linkIconPictureURL = URL(string: model.postLinkIconImage) else {
                    return
                }
                viewModels.append(
                    .acceptedRequest(
                        viewModel: AcceptedRequestNotificationCellViewModel(
                            username: username,
                            linkIconPictureUrl: linkIconPictureURL,
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
                withIdentifier: AcceptedRequestedNotificationTableViewCell.identifer,
                for: indexPath
            ) as? AcceptedRequestedNotificationTableViewCell else {
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
              let vc = PostLinkViewController(link: linkModel, owner: username)
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

extension NotificationsViewController: LikeNotificationTableViewCellDelegate, CommentNotificationTableViewCellDelegate, FollowNotificationTableViewCellDelegate, RequestNotificationTableViewCellDelegate, AcceptNotificationTableCellDelegate, AcceptedRequestNotificationTableViewCellDelegate
{
   
    func acceptedRequestedNotificationTableViewCell(_ cell: AcceptedRequestedNotificationTableViewCell, didTapPostWith viewModel: AcceptedRequestNotificationCellViewModel) {
        // do something when post is tapped!
    }
    

    func requestNotificationTableViewCell(_ cell: RequestNotificationTableViewCell, didTapButton isRequest: Bool, viewModel: RequestNotificationCellViewModel) {
        
        let userRequesting = viewModel.username
        let id = NotificationsManager.newIdentifier()
        let linkIconString = viewModel.linkIconPictureUrl.absoluteString
        let linkPost = viewModel.postUrl.absoluteString
        // remove the user who requested from requested database
        // add to newUserArray
        // send a notification to person who made request
        
        DatabaseManager.shared.updateGuestList(state: .accepted, linkId: viewModel.postId, eventUsername: userRequesting) { sucess in
            if sucess {
                // send the requested user a notification saying he is invited to event!
                
                let acceptedRequest = LinkNotification(identifer: id, notificationType: 6, profilePictureUrl: linkIconString, postLinkIconImage: linkIconString, username: userRequesting, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: false, isAccepted: false, postId: viewModel.postId, postUrl: linkPost )
                
                
                NotificationsManager.shared.create(notification: acceptedRequest, for: userRequesting)
            } else {
                
                print("Couldn't update the guestList")
            }
        }
    
    }
    
    func acceptNotificationTableCell(_ cell: AcceptNotificationTableCell, didTapButton isAccepted: Bool, viewModel: AcceptNotificationCellViewModel) {
    
        let userRequesting = viewModel.username
        let id = NotificationsManager.newIdentifier()
        let linkIconString = viewModel.linkIconPictureUrl.absoluteString
        let linkPost = viewModel.postUrl.absoluteString
        
        DatabaseManager.shared.updateGuestListForInvitesOnly(state: .accepted, linkId: viewModel.postId, eventUsername: userRequesting) { sucess in
            if sucess {
                // send the requested user a notification saying he is invited to event!
                
                let acceptedRequest = LinkNotification(identifer: id, notificationType: 6, profilePictureUrl: linkIconString, postLinkIconImage: linkIconString, username: userRequesting, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: false, isAccepted: false, postId: viewModel.postId, postUrl: linkPost )
                
                
                NotificationsManager.shared.create(notification: acceptedRequest, for: userRequesting)
            } else {
                
                print("Couldn't update the guestList")
            }
        }
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
        let username = viewModel.username
        DatabaseManager.shared.updateRelationship(
            state: isFollowing ? .follow : .unfollow,
            for: username
        ) { [weak self] success in
            if !success {
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
            } else {
                
                let id = NotificationsManager.newIdentifier()
                
                
                let followNotification = LinkNotification(identifer: id, notificationType: 3, profilePictureUrl: "", postLinkIconImage: "", username: viewModel.username, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: false, isAccepted: false, postId: "", postUrl: nil)
                
            
                
                NotificationsManager.shared.create(notification: followNotification, for: viewModel.username)
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

                let vc = PostLinkViewController(link: link, owner: username)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    
}

