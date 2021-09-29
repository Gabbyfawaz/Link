//
//  ProfileViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

/// Reusable controller for Profile
final class ProfileViewController: UIViewController {

    private let user: User

    private var isCurrentUser: Bool {
        return user.username.lowercased() == UserDefaults.standard.string(forKey: "username")?.lowercased() ?? ""
    }

//    private var collectionView: UICollectionView?
    
    
   private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    layout.itemSize = CGSize(width: 150, height: 150)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        
        return collectionView
    }()


    private var headerViewModel: ProfileHeaderViewModel?

//    private var posts: [Post] = []
    
    private var links: [LinkModel] = []
    
    private var observer: NSObjectProtocol?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    public let userInfoContainerView = ProfileHeaderUserInfoView()

    // MARK: - Init

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        view.backgroundColor = .systemBackground
        
        
        
        configureNavBar()
        fetchProfileInfo()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tap)
        view.insertSubview(imageView, at: 0)
        view.insertSubview(userInfoContainerView, at: 1)
        view.insertSubview(collectionView, at: 2)
        userInfoContainerView.countContainerView.delegate = self
        userInfoContainerView.delegate = self
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        
       guard let viewModel = headerViewModel else {
            return
        }
        
        DispatchQueue.main.async {
            self.userInfoContainerView.configure(with: viewModel)
            self.imageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)
        }
        
        if isCurrentUser {
            observer = NotificationCenter.default.addObserver(
                forName: .didPostNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.links.removeAll()
                self?.fetchProfileInfo()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = view.bounds
        userInfoContainerView.frame = CGRect(x: 0, y: view.height/2-100, width: view.width, height: view.height/2)
        collectionView.frame = CGRect(x: 0, y: view.height-view.height/4.5-100, width: view.width, height: view.height/4.5)
    }
    
    @objc private func didSwipeRight() {
        
        tabBarController?.tabBar.isHidden = false
        navigationController?.popToRootViewController(animated: true)
    }
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
        DatabaseManager.shared.getUserInfo(username: user.username) { userInfo in
            name = userInfo?.name
            bio = userInfo?.bio
        }

        // Profile picture url
        group.enter()
        StorageManager.shared.profilePictureURL(for: user.username) { url in
            defer {
                group.leave()
            }
            profilePictureUrl = url
        }

        // if profile is not for current user,
        if !isCurrentUser {
            // Get follow state
            group.enter()
            DatabaseManager.shared.isFollowing(targetUsername: user.username) { isFollowing in
                defer {
                    group.leave()
                }
                print(isFollowing)
                buttonType = .follow(isFollowing: isFollowing)
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
                 return
             }
             
             DispatchQueue.main.async {
                 self.userInfoContainerView.configure(with: viewModel)
                 self.imageView.sd_setImage(with: viewModel.profilePictureUrl, completed: nil)
             }

            self.collectionView.reloadData()
        }
    }

    private func configureNavBar() {
        if isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "gear"),
                style: .done,
                target: self,
                action: #selector(didTapSettings)
            )
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
//        let vc = PostLinkViewController(post: link, owner: user.username)
//        navigationController?.pushViewController(vc, animated: true)
        
        let vc = PostLinkViewController(link: link, owner: user.username)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true, completion: nil)
        
        
      
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//           let itemWidth = collectionView.bounds.height
//           let itemHeight = collectionView.bounds.height
//           return CGSize(width: itemWidth, height: itemHeight)
//   }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.height, height: collectionView.height)
    }
}

extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func profileHeaderCollectionReusableViewDidTapProfilePicture(_ header: ProfileHeaderCollectionReusableView) {

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
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        
        
//            StorageManager.shared.uploadBackgroundImage(
//                username: user.username,
//                data: image.pngData()
//            ) { [weak self] success in
//                if success {
//                    self?.headerViewModel = nil
//                    self?.links = []
//                    self?.fetchProfileInfo()
//                }
//            }

        
    
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

    func profileHeaderCountViewDidTapEditProfile(_ containerView: ProfileHeaderCountView) {
        let vc = EditProfileViewController()
        vc.completion = { [weak self] in
            self?.headerViewModel = nil
            self?.fetchProfileInfo()
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }

    func profileHeaderCountViewDidTapFollow(_ containerView: ProfileHeaderCountView) {
        DatabaseManager.shared.updateRelationship(
            state: .follow,
            for: user.username
        ) { [weak self] success in
            if !success {
                print("failed to follow")
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            } else {
                
                let id = NotificationsManager.newIdentifier()
                guard let user = self?.user.username else {
                    return
                }
                
                print("This user is: \(user)")
                
                
                let followNotification = LinkNotification(identifer: id, notificationType: 3, profilePictureUrl: "", postLinkIconImage: "", username: user, dateString: DateFormatter.formatter.string(from: Date()), isFollowing: false, isAccepted: false, postId: "", postUrl: nil)

                NotificationsManager.shared.create(notification: followNotification, for: user)
                
                print("The follow notification has been working!")
            }
        }
    }

    func profileHeaderCountViewDidTapUnFollow(_ containerView: ProfileHeaderCountView) {
        DatabaseManager.shared.updateRelationship(
            state: .unfollow,
            for: user.username
        ) { [weak self] success in
            if !success {
                print("failed to follow")
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
}

extension ProfileViewController: ProfileHeaderUserInfoViewDelegate {
    
    func profileHeaderUserInfoViewDidTapProfilePicture(_ view: ProfileHeaderUserInfoView) {

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
                let pickerProfile = UIImagePickerController()
                pickerProfile.sourceType = .camera
                pickerProfile.allowsEditing = true
                pickerProfile.delegate = self
                self?.present(pickerProfile, animated: true)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let pickerProfile = UIImagePickerController()
                pickerProfile.allowsEditing = true
                pickerProfile.sourceType = .photoLibrary
                pickerProfile.delegate = self
                self?.present(pickerProfile, animated: true)
            }
        }))
        present(sheet, animated: true)
    }
    
    
}

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

