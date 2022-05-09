//
//  ProfileViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

/// Reusable controller for Profile
final class ProfileViewController: UIViewController {

    // MARK: PROPERTIES
    
    private let user: User
    private var isCurrentUser: Bool {
        return user.username.lowercased() == UserDefaults.standard.string(forKey: "username")?.lowercased() ?? ""
    }
    private var isFollowing = false
    private var isRequesting = false
    private var headerViewModel: ProfileHeaderViewModel?
    private var links: [LinkModel] = []
    private var observer: NSObjectProtocol?
//    public let userInfoContainerView = ProfileHeaderUserInfoView()
    private var action = ProfileButtonType.edit
    public let actionButton = LinkFollowButton()
//    public let actionButton = ProfileHeaderCountView().actionButton
    private var isPrivate = false
    public let countContainerView = ProfileHeaderCountView()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
//        label.backgroundColor = .white
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
//        label.layer.shadowColor = UIColor.black.cgColor
//        label.layer.shadowRadius = 3.0
//        label.layer.shadowOpacity = 1.0
//        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
//        label.backgroundColor = .white
        label.font = .systemFont(ofSize: 18)
//        label.layer.shadowColor = UIColor.black.cgColor
//        label.layer.shadowRadius = 3.0
//        label.layer.shadowOpacity = 1.0
//        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()

    
   private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: 200, height: 280)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .none
       collectionView.isHidden = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        
        return collectionView
    }()

    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private var maskImageView: UIImageView = {
        let maskImageView = UIImageView()
        maskImageView.contentMode = .scaleAspectFit
        maskImageView.image = #imageLiteral(resourceName: "mask")
        return maskImageView
    }()
    

    // MARK: - Init

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        fetchProfileInfo() // going into the database and collecting data & model
        addSubviews()
        collectionView.delegate = self
        collectionView.dataSource = self
        countContainerView.delegate = self
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        // used for refershing the page!
        if isCurrentUser {
            observer = NotificationCenter.default.addObserver(
                forName: .didPostNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.links.removeAll()
                self?.fetchProfileInfo()
//                self?.configureActionButton(headerViewModel: viewModel)
            }
        }
        
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }

    // MARK: LAYOUT SUBVIEWS
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let imageSize = view.width/3
        imageView.frame = CGRect(x: (view.width-imageSize)/2, y: imageSize/1.4, width: imageSize, height: imageSize
)
        nameLabel.frame = CGRect(x: (view.width-imageSize*2)/2, y: imageView.bottom+20, width: imageSize*2, height: 25)
        
        actionButton.frame = CGRect(x:(view.width-view.width/4)/2 , y: nameLabel.bottom+20, width: view.width/4, height: 30)

        bioLabel.frame = CGRect(x: 5, y: actionButton.bottom+10, width: view.width-10, height: 50)
        countContainerView.frame = CGRect(x: 10, y: bioLabel.bottom+10, width: view.width-10, height: 100)
//        imageView.frame = view.bounds
//        userInfoContainerView.frame = CGRect(x: 0, y: view.height/2-100, width: view.width, height: view.height/2)
        
        collectionView.frame = CGRect(x: 5, y: countContainerView.bottom-30, width: view.width-10, height: 300)
        
        maskImageView.frame = imageView.bounds
        imageView.mask = maskImageView
    }
    
    //MARK: ACTIONS
    
    
    private func addSubviews() {
        view.addSubview(collectionView)
        view.addSubview(nameLabel)
        view.addSubview(bioLabel)
        view.addSubview(countContainerView)
        view.addSubview(imageView)
        view.addSubview(maskImageView)
        view.addSubview(actionButton)
    }
    
    private func configureNavBar() {
        title = "\(user.username)"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .label
        if isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "gear"),
                style: .done,
                target: self,
                action: #selector(didTapSettings)
            )
        }
        

    }
    
    private func sendNotification(notificationType: Int) {
        let id = NotificationsManager.newIdentifier()
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        let followNotification = LinkNotification(identifer: id, notificationType: notificationType, username: username, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: [false], isRequesting: [], postId: "", postUrl: "")

        NotificationsManager.shared.create(notification: followNotification, for: user.username)
    }
    
    private func configurePrivateCollectionView() {
        if isPrivate {
            DispatchQueue.main.async {
                if self.isFollowing {
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = false
                } else {
                    self.collectionView.reloadData()
                    self.collectionView.isHidden = true
                }
               
            }
        } else {
            DispatchQueue.main.async {
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
            }
        }
    }
    
    

    private func handleFollowAndUnfollowButton() {
        if self.isFollowing {
            // unfollow

            // call an alert to say if the user is sure they should unfollow
            DatabaseManager.shared.updateRelationship(state: .unfollow, for: user.username) { success in
                if !success {
                    DispatchQueue.main.async {
                        print("failed to follow ")
                        self.collectionView.reloadData()
                    }
                }
            }
            
        } else {
            // follow
            
            
            
            DatabaseManager.shared.updateRelationship(state: .follow, for: user.username) { success in
                if success {
                    // send notifucation that user is following
                    self.sendNotification(notificationType: 3)
                    
                } else {
                    DispatchQueue.main.async {
                        print("failed to unfollow")
                        self.collectionView.reloadData()
                    }
                }
            }
        }

        self.isFollowing = !isFollowing
        actionButton.configure(for: isFollowing ? .unfollow : .follow)
    }
    
    private func handleRequestButton() {
        if isRequesting {
            DatabaseManager.shared.updateRequestingState(targetUsername: user.username, state: .request) { success in
                if !success {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } else {
                    // send a notification that user is requesting
                }
            }
        } else {
            DatabaseManager.shared.updateRequestingState(targetUsername: user.username, state: .requesting) { success in
                if !success {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } else {
                    // send a notification that user is requesting
                }
            }
            
        }
        isRequesting = !isRequesting
        actionButton.configure(for: isRequesting ? .requested : .follow)
        

        
       
    }
    
    private func configureActionButton(headerViewModel: ProfileHeaderViewModel?) {
        guard let headerViewModel = headerViewModel else {
//            return
            fatalError("The viewModel is empty")
        }
        self.action = headerViewModel.buttonType

        switch headerViewModel.buttonType {
        case .edit:
            actionButton.backgroundColor = .label
            actionButton.setTitle("Edit Profile", for: .normal)
            actionButton.setTitleColor(.systemBackground, for: .normal)
//            actionButton.layer.borderWidth = 0.5
//            actionButton.layer.borderColor = UIColor.tertiaryLabel.cgColor
        case .follow(let isFollowing):
            
            if isPrivate {
              
                if isFollowing {
                    actionButton.configure(for:  .unfollow)
                } else if !isFollowing {
                    actionButton.configure(for: .follow)
                }
                
                if isRequesting {
                        actionButton.configure(for: .requested)
                    }
      
                
            }  else {
                print("The value of isFollowing: \(self.isFollowing)")
                actionButton.configure(for: isFollowing ? .unfollow : .follow)
            }
            
        }
    }

    
    @objc private func didTapActionButton() {
        switch action {
        case.edit:
            let vc = EditProfileViewController()
            vc.completion = { [weak self] in
                self?.headerViewModel = nil
                self?.fetchProfileInfo()
            }
            let navVC = UINavigationController(rootViewController: vc)
            present(navVC, animated: true)
        case .follow:
            
            if self.isPrivate {
                
                if isFollowing {
                    
                    
                    let actionsheet = UIAlertController(title: "Are you sure you want to unfollow this user?", message: "", preferredStyle: .actionSheet)
                    actionsheet.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                        // unfollow user
                        self.handleFollowAndUnfollowButton()
                        DispatchQueue.main.async {
                            self.collectionView.isHidden = true
                        }
                    }))
                    actionsheet.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    self.present(actionsheet, animated: true)
                                          
                
                    
                } else {
                    handleRequestButton()
                    
                }
                
            } else {
                
                if isFollowing {
                    let actionsheet = UIAlertController(title: "Are you sure you want to unfollow this user?", message: "", preferredStyle: .actionSheet)
                    actionsheet.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
                        // unfollow user
                        self.handleFollowAndUnfollowButton()
                
                    }))
                    actionsheet.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    self.present(actionsheet, animated: true)
                } else {
                    handleFollowAndUnfollowButton()
                }
               
                
                

            }
            
        }
        
    }
            
            

    
    
    @objc private func didSwipeRight() {
        
//        tabBarController?.tabBar.isHidden = false
//        tabBarController?.selectedIndex = 0
//        self.tabBarController?.tabBar.isHidden = false 
        
    }
    
    //MARK: REMOVE THIS, WE WILL ADD TO THE DID EDIT VC
    
    @objc private func didTapImage() {
        print("Image has been tapped")
        guard isCurrentUser else {
            return
        }

        let sheet = UIAlertController(
            title: "Change Picture",
            message: "Update your photo to reflect your best self.",
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in

            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        present(sheet, animated: true)
    }
    


    private func fetchProfileInfo() {
        let username = user.username

        let group = DispatchGroup()

        // Fetch Posts
        group.enter()
        DatabaseManager.shared.getAllLinks(for: username) { [weak self] result in
            defer {
                group.leave()
            }

            switch result {
            case .success(let links):
                self?.links = links
            case .failure:
                break
            }
        }

        // Fetch Profiel Header Info

        var profilePictureUrl: URL?
        var buttonType: ProfileButtonType = .edit
        var followers = 0
        var following = 0
        var posts = 0
        var name: String?
        var bio: String?

        // Counts (3)
        group.enter()
        DatabaseManager.shared.getUserCounts(username: user.username) { result in
            defer {
                group.leave()
            }
            posts = result.posts
            followers = result.followers
            following = result.following
        }


        // Bio, name
        group.enter()
        DatabaseManager.shared.getUserInfo(username: user.username) { userInfo in
            defer {
                group.leave()
            }
            name = userInfo?.name
            bio = userInfo?.bio
        }

        // Profile picture url
        group.enter()
        StorageManager.shared.profilePictureURL(for: user.username) { url in
            defer {
                group.leave()
            }
            
            guard let url = url else {
                return
//                fatalError("The url is nil")
            }
            profilePictureUrl = url
        }

        // if profile is not for current user,
        if !isCurrentUser {
            
            group.enter()
            DatabaseManager.shared.isFollowing(targetUsername: username) { isFollowing in
                defer {
                    group.leave()
                }
                self.isFollowing = isFollowing
                buttonType = .follow(isFollowing: isFollowing)
            }
            
//            group.enter()
            DatabaseManager.shared.isUserPrivate(username: username) { isPrivate in
//                defer {
//                    group.leave()
//                }
                self.isPrivate = isPrivate
            }
            
//            group.enter()
            DatabaseManager.shared.isRequesting(targetUsername: username) { isRequesting in
//                defer {
//                    group.leave()
//                }
                self.isRequesting = isRequesting
            }
            

        }
        
    
        

        group.notify(queue: .main) {
            
            self.headerViewModel = ProfileHeaderViewModel(
                profilePictureUrl: profilePictureUrl,
                followerCount: followers,
                followingICount: following,
                postCount: posts,
                buttonType: buttonType,
                name: name,
                bio: bio
            )
            guard let viewModel = self.headerViewModel else {
                 fatalError("There view model is returing zero")
             }
             
    
             DispatchQueue.main.async {
//                 self.userInfoContainerView.configure(with: viewModel)
                 self.countContainerView.configure(with: viewModel)
                 self.nameLabel.text = name
                 self.bioLabel.text = bio
                 self.imageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)
                 self.configureActionButton(headerViewModel: viewModel)
                 self.configurePrivateCollectionView()
             }

            self.collectionView.reloadData()
        }
    }



    @objc func didTapSettings() {
        let vc = SettingsViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return links.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postString = links[indexPath.row].postArrayString[0]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: URL(string: postString))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier,
                for: indexPath
              ) as? ProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        if let viewModel = headerViewModel {
            headerView.configure(with: viewModel)
            headerView.userInfoContainerView.countContainerView.delegate = self
        }
        headerView.delegate = self
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let link = links[indexPath.row]
        let vc = EventViewController(link: link, owner: user.username)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
        
        
      
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.height, height: collectionView.height)
    }
}

extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func profileHeaderCollectionReusableViewDidTapProfilePicture(_ header: ProfileHeaderCollectionReusableView) {

        guard isCurrentUser else {
            fatalError("This is not the current user")
        }

        let sheet = UIAlertController(
            title: "Change Picture",
            message: "Update your photo to reflect your best self.",
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in

            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        }))
        present(sheet, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            fatalError("Retrieved no image")
        }
        
    
        StorageManager.shared.uploadProfilePicture(
            username: user.username,
            data: image.pngData()
        ) { [weak self] success in
            if success {
                self?.headerViewModel = nil
                self?.links = []
                self?.fetchProfileInfo()
            }
        }
    }
}


// MARK: IMPORTANT! THIS IS THE DELEGATE FOR THE FOLLOWERS/FOLLOWING/EDIT BUTTONS

extension ProfileViewController: ProfileHeaderCountViewDelegate {
    func profileHeaderCountViewDidTapFollowers(_ containerView: ProfileHeaderCountView) {
        let vc = ListViewController(type: .followers(user: user))
        navigationController?.pushViewController(vc, animated: true)
    }

    func profileHeaderCountViewDidTapFollowing(_ containerView: ProfileHeaderCountView) {
        let vc = ListViewController(type: .following(user: user))
        navigationController?.pushViewController(vc, animated: true)
    }

    func profileHeaderCountViewDidTapPosts(_ containerView: ProfileHeaderCountView) {
//        guard links.count >= 18 else {
//            return
//        }
//        collectionView.setContentOffset(CGPoint(x: 0, y: view.width * 0.4),
//                                         animated: true)
    }

//    func profileHeaderCountViewDidTapEditProfile(_ containerView: ProfileHeaderCountView) {
//        let vc = EditProfileViewController()
//        vc.completion = { [weak self] in
//            self?.headerViewModel = nil
//            self?.fetchProfileInfo()
//        }
//        let navVC = UINavigationController(rootViewController: vc)
//        present(navVC, animated: true)
//    }

//    func profileHeaderCountViewDidTapFollow(_ containerView: ProfileHeaderCountView) {
//        DatabaseManager.shared.updateRelationship(
//            state: .follow,
//            for: user.username
//        ) { [weak self] success in
//            if !success {
//                print("failed to follow")
//                DispatchQueue.main.async {
//                    self?.collectionView.reloadData()
//                }
//            } else {
//
//                let id = NotificationsManager.newIdentifier()
//                guard let user = self?.user.username else {
//                    return
//                }
//
//                print("This user is: \(user)")
//
//
//                let followNotification = LinkNotification(identifer: id, notificationType: 3, profilePictureUrl: "", postLinkIconImage: "", username: user, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: false, isAccepted: false, postId: "", postUrl: nil)
//
//                NotificationsManager.shared.create(notification: followNotification, for: user)
//
//                print("The follow notification has been working!")
//            }
//        }
//    }

//    func profileHeaderCountViewDidTapUnFollow(_ containerView: ProfileHeaderCountView) {
//        DatabaseManager.shared.updateRelationship(
//            state: .unfollow,
//            for: user.username
//        ) { [weak self] success in
//            if !success {
//                print("failed to follow")
//                DispatchQueue.main.async {
//                    self?.collectionView.reloadData()
//                }
//            }
//        }
//    }
}

//extension ProfileViewController: ProfileHeaderUserInfoViewDelegate {
//
//    func profileHeaderUserInfoViewDidTapProfilePicture(_ view: ProfileHeaderUserInfoView) {
//
//        guard isCurrentUser else {
//            return
//        }
//
//        let sheet = UIAlertController(
//            title: "Change Picture",
//            message: "Update your photo to reflect your best self.",
//            preferredStyle: .actionSheet
//        )
//
//        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
//
//            DispatchQueue.main.async {
//                let pickerProfile = UIImagePickerController()
//                pickerProfile.sourceType = .camera
//                pickerProfile.allowsEditing = true
//                pickerProfile.delegate = self
//                self?.present(pickerProfile, animated: true)
//            }
//        }))
//        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
//            DispatchQueue.main.async {
//                let pickerProfile = UIImagePickerController()
//                pickerProfile.allowsEditing = true
//                pickerProfile.sourceType = .photoLibrary
//                pickerProfile.delegate = self
//                self?.present(pickerProfile, animated: true)
//            }
//        }))
//        present(sheet, animated: true)
//    }
//
//
//}

//extension ProfileViewController {
//    func configureCollectionView() {
//        let collectionView = UICollectionView(
//            frame: .zero,
//            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in
//
//                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
//
//                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
//
//
//                let group = NSCollectionLayoutGroup.horizontal(
//                    layoutSize: NSCollectionLayoutSize(
//                        widthDimension: .fractionalWidth(1),
//                        heightDimension: .fractionalWidth(1/3)
//                    ),
//                    subitem: item,
//                    count: 3
//                )
//
//                let section = NSCollectionLayoutSection(group: group)
//
////                section.boundarySupplementaryItems = [
////                    NSCollectionLayoutBoundarySupplementaryItem(
////                        layoutSize: NSCollectionLayoutSize(
////                            widthDimension: .fractionalWidth(1),
////                            heightDimension: .fractionalHeight(0.75)
////                        ),
////                        elementKind: UICollectionView.elementKindSectionHeader,
////                        alignment: .top
////                    )
////                ]
//
//                return section
//            })
//        )
//        collectionView.register(PhotoCollectionViewCell.self,
//                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
//        collectionView.register(
//            ProfileHeaderCollectionReusableView.self,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier
//        )
//        collectionView.backgroundColor = .systemBackground
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        view.addSubview(collectionView)
//
////        let layout = UICollectionViewFlowLayout()
////        layout.scrollDirection = .horizontal
////        layout.minimumInteritemSpacing = view.width
////        layout.minimumLineSpacing = 0
////        collectionView.collectionViewLayout = layout
//
//        self.collectionView = collectionView
//    }
//}

