//
//  CreateLinkViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import CoreLocation

class CreateLinkViewController: UIViewController {
    
    //MARK: - Properties
    
    private var image: UIImage
    private var locationTitle: String?
    private var coordinates: CLLocationCoordinate2D?
    private var isLocked = false
    private var resultsArray = [SearchResult]()
    private var postDateString: String?
    private var typeofLinkArray = ["Custom", "Party", "Sneaky Link", "Dine", "Birthday Party", "Concert", "Expedition"]
    
    private var mainImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 20
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private var linkTypeImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 25
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .black
        return iv
    }()
    
    private var captionImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "pencil")
        iv.tintColor = .black
        return iv
    }()
    
    private var captionTextField: UITextField = {
            let textField = UITextField()
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
            textField.leftViewMode = .always
            textField.backgroundColor = .systemBackground
            textField.placeholder = "Caption"
        textField.font = .systemFont(ofSize: 21, weight: .medium)
            return textField
        }()
        
    
    private var linkTypeTextField: UITextField = {
            let textField = UITextField()
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
            textField.leftViewMode = .always
            textField.backgroundColor = .systemBackground
            textField.text = "Link Type"
        textField.font = .systemFont(ofSize: 21, weight: .medium)
            return textField
        }()
        
    
    private var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.isHidden = true
        return picker
    }()
    
    private var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isUserInteractionEnabled = true
        return scroll
    }()
    

    
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Create Link"
//        label.font = UIFont.systemFont(ofSize: 50, weight: .bold)
//        label.textColor = .purple
//        return label
//    }()
    
//    private let barButtonItem: UIButton = {
//        let barButton = UIButton()
//        barButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
//        barButton.tintColor = .purple
//        barButton.layer.borderColor = UIColor.purple.cgColor
//        barButton.layer.borderWidth = 2
//        return barButton
//    }()
    
    private let privacyButtonItem: UIButton = {
        let barButton = UIButton()
        barButton.setImage(UIImage(systemName: "lock.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
        barButton.tintColor = .black
        return barButton
    }()
    
 
    
    private let peopleInvitedButton: UIButton = {
        let barButton = UIButton()
        barButton.setImage(UIImage(systemName: "person.2.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
        barButton.tintColor = .black
        return barButton
    }()
    
    private var peopleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 70, height: 70)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.layer.cornerRadius = 8
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AddUsersToLinkCollectionViewCell.self,
                                forCellWithReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier)
        return collectionView
    }()
    
    
    private let locationImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "mappin.and.ellipse")
        iv.tintColor = .black
        return iv
    }()
    
    private let locationTypeTextField: UITextField = {
        let textField = UITextField()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        textField.leftViewMode = .always
        textField.backgroundColor = .systemBackground
        textField.placeholder = "Enter Location"
        textField.font = .systemFont(ofSize: 21, weight: .medium)
        return textField
    }()
    
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Info"
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    
    private let infoTextField: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = .secondarySystemBackground
        textField.font = .systemFont(ofSize: 21, weight: .regular)
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private let calenderImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        iv.tintColor = .black
        return iv
    }()
    
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.countDownDuration = TimeInterval()
        return datePicker
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Create Link"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(mainImageView)
        scrollView.addSubview(linkTypeImage)
        scrollView.addSubview(linkTypeTextField)
        scrollView.addSubview(privacyButtonItem)
        scrollView.addSubview(pickerView)
        scrollView.addSubview(locationImageView)
        scrollView.addSubview(peopleInvitedButton)
        scrollView.addSubview(peopleCollectionView)
        scrollView.addSubview(locationImageView)
        scrollView.addSubview(locationTypeTextField)
        scrollView.addSubview(infoLabel)
        scrollView.addSubview(infoTextField)
        scrollView.addSubview(datePicker)
        scrollView.addSubview(calenderImageView)
        scrollView.addSubview(captionImage)
        scrollView.addSubview(captionTextField)
        scrollView.contentSize = CGSize(width: (view.width), height: (1000))
        pickerView.delegate = self
        pickerView.dataSource = self
        peopleCollectionView.delegate = self
        peopleCollectionView.dataSource = self
        linkTypeTextField.delegate = self
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        
        peopleInvitedButton.addTarget(self, action: #selector(didTapPeopleButton), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        
        linkTypeImage.addGestureRecognizer(tap)

        privacyButtonItem.addTarget(self, action: #selector(didTapLock), for: .touchUpInside)
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationTypeTextField.text = self.locationTitle
    }
    
    //MARK: - Init
    
    init(image: UIImage, locationTitle: String?, coordinates: CLLocationCoordinate2D?) {
        self.image = image
        self.locationTitle = locationTitle
        self.coordinates = coordinates
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LayoutSubviews
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        mainImageView.frame = CGRect(x: 15, y: 20, width: view.width-30, height: view.width)
        mainImageView.image = image
        linkTypeImage.frame = CGRect(x: 15, y: mainImageView.bottom+30, width: 50, height: 50)
        linkTypeTextField.frame = CGRect(x: linkTypeImage.right+20, y: mainImageView.bottom+30, width: view.width-linkTypeImage.width-privacyButtonItem.width-60, height: 50)
        privacyButtonItem.frame = CGRect(x: linkTypeTextField.right+10, y: mainImageView.bottom+30, width: 45, height: 45)
        pickerView.frame = CGRect(x: linkTypeImage.right+20, y: mainImageView.bottom+10, width: view.width-linkTypeImage.width-privacyButtonItem.width-50, height: 100)
        captionImage.frame = CGRect(x: 15, y: linkTypeImage.bottom+40, width: 40, height: 40)
        captionTextField.frame = CGRect(x: captionImage.right+20, y: linkTypeImage.bottom+30, width:  view.width-captionImage.width-50, height: 50)
        
        peopleInvitedButton.frame = CGRect(x: 15, y: captionImage.bottom+30+25, width: 50, height: 50)
        peopleCollectionView.frame = CGRect(x: peopleInvitedButton.right+20, y: captionImage.bottom+30, width: view.width-peopleInvitedButton.width-50, height: 100)
        locationImageView.frame = CGRect(x: 15, y: peopleCollectionView.bottom+20, width: 45, height: 45)
        locationTypeTextField.frame = CGRect(x: locationImageView.right+20, y:peopleCollectionView.bottom+20 , width: view.width-locationImageView.width-50, height: 50)
        infoLabel.frame = CGRect(x: 15, y: locationImageView.bottom+30, width: 50, height: 50)
        infoTextField.frame = CGRect(x: infoLabel.right+20, y: locationImageView.bottom+30, width: view.width-infoLabel.width-50, height: 150)
        
        calenderImageView.frame = CGRect(x: 15, y: infoTextField.bottom+30, width: 50, height: 40)
        
        datePicker.frame = CGRect(x: calenderImageView.right+20, y: infoTextField.bottom+30, width: view.width-calenderImageView.width-20, height: 50)
        
    }
    //MARK: - Actions
    
    
    @objc private func didTapDone() {
        
        infoTextField.resignFirstResponder()
        let extraInfo = infoTextField.text ?? ""
        let info = captionTextField.text ?? ""

        // Generate post ID
        guard let newPostID = createNewPostID(),
              let stringDate = String.date(from: Date())
        else {
            return
        }
        
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let locationTitle = self.locationTitle,
              let coordinates = self.coordinates,
              let linkTypeName = linkTypeTextField.text else {
            return
        }
        
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude

        // Upload Post
        StorageManager.shared.uploadLinkPost(
            data: image.pngData(),
            id: newPostID
        ) { newLinkPostDownloadURL in
            guard let postLinkUrl = newLinkPostDownloadURL else {
                print("error: failed to upload")
                return
            }
            
            StorageManager.shared.uploadLinkTypeImage(
                data: self.linkTypeImage.image?.pngData(),
                id: newPostID) { (url) in
                guard let linkTypeImageDownloadURL = url else {
                    print("error: failed to upload")
                    return
                }

            // New Post
            let newLink = LinkModel(
                id: newPostID,
                user: username,
                info: info,
                location: Coordinates(latitude: latitude, longitude: longitude),
                locationTitle: locationTitle,
                linkTypeName: linkTypeName,
                invites: self.resultsArray,
                postedDate: stringDate,
                postUrlString: postLinkUrl.absoluteString,
                likers: [],
                isPrivate: self.isLocked,
                linkTypeImage: linkTypeImageDownloadURL.absoluteString,
                extraInformation: extraInfo)

            // Update Database
            DatabaseManager.shared.createLink(newLink: newLink) { [weak self] finished in
                guard finished else {
                    return
                }
                DispatchQueue.main.async {
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.tabBarController?.selectedIndex = 0
                    self?.navigationController?.popToRootViewController(animated: false)

                    NotificationCenter.default.post(name: .didPostNotification,
                                                    object: nil)
                }
            }
            }
        }

    }
    
    private func createNewPostID() -> String? {
        let timeStamp = Date().timeIntervalSince1970
        let randomNumber = Int.random(in: 0...1000)
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return nil
        }

        return "link_\(username)_\(randomNumber)_\(timeStamp)"
    }
    
    @objc private func didTapPeopleButton() {
        print("did tap people button")
        
        let vc = AddNewPeopleToLinkViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {return}
            strongSelf.resultsArray.append(contentsOf: result)
            strongSelf.peopleCollectionView.reloadData()
            print("results array: \(strongSelf.resultsArray)")
    }
        
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    @objc private func didTapImage() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach a photo from",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }
    
    @objc private func didTapLock() {
        isLocked = !isLocked
        
        if isLocked {
            privacyButtonItem.setImage( UIImage(systemName: "lock.open.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
            
            print(isLocked)
        } else {
            privacyButtonItem.setImage(UIImage(systemName: "lock.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
            print(isLocked)
        }
    }
    
    func dateChanged(_ sender: UIDatePicker) {
        let postDateString = String.date(from: sender.date)
        self.postDateString = postDateString
        
        print("The string: \(postDateString)")
        }
    
}

extension CreateLinkViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        linkTypeImage.image = image
    }
}
    

    


extension CreateLinkViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count for results: \(resultsArray.count)")
        return resultsArray.count
        //viewModels.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = resultsArray[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier,
                for: indexPath
        ) as? AddUsersToLinkCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: model)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
}

extension CreateLinkViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typeofLinkArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typeofLinkArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.linkTypeTextField.isHidden = false
        self.pickerView.isHidden = true
         self.linkTypeTextField.text = typeofLinkArray[row]
    }

    
    
}

extension CreateLinkViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.linkTypeTextField.isHidden = true
         self.pickerView.isHidden = false
         return false
    }
}

