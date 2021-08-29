//
//  CreateLinkViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

//import UIKit
//import CoreLocation
//import MapKit
//
//struct Section {
//    let title: String
//    let view: UIView
//}
//class CreateLinkViewController: UIViewController, MKMapViewDelegate {
//
//    //MARK: - Properties
//
//    private var arrayOfImage: [UIImage]
//    private var iconImage: UIImage
//    private var locationTitle: String?
//    private var coordinates: CLLocationCoordinate2D?
//    private var isLocked = false
//    private var resultsArray = [SearchResult]()
//    private var postDateString: String?
//    private var typeOfLink: String
//    private var caption: String
//    private var mapIdentifier = "mapIdentifier"
//
//
//
//
//    private let mapView: MKMapView = {
//        let mapView = MKMapView()
//        mapView.layer.masksToBounds = true
//        mapView.layer.cornerRadius = 10
//        return mapView
//    }()
//
//
//    private var linkTypeImage: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFill
//        iv.layer.masksToBounds = true
//        iv.layer.cornerRadius = 30
//        iv.layer.borderColor = UIColor.white.cgColor
//        iv.layer.borderWidth = 2
//        iv.isUserInteractionEnabled = true
//        iv.backgroundColor = .white
//        return iv
//    }()
//
//
//    private var mapTypeImage: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFill
//        iv.layer.masksToBounds = true
//        iv.layer.cornerRadius = 20
//        iv.layer.borderColor = UIColor.white.cgColor
//        iv.layer.borderWidth = 2
//        iv.isUserInteractionEnabled = true
//        iv.frame.size = CGSize(width: 40, height: 40)
//        iv.backgroundColor = .white
//        return iv
//    }()
//
//
//    private var captionImage: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(systemName: "pencil")
//        iv.tintColor = .black
//        return iv
//    }()
//
//    private var captionTextField: UITextField = {
//            let textField = UITextField()
//            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
//            textField.leftViewMode = .always
//            textField.backgroundColor = .systemBackground
//            textField.placeholder = "Caption"
//        textField.font = .systemFont(ofSize: 21, weight: .medium)
//            return textField
//        }()
//
//
//    private var linkTypeTextField: UITextField = {
//            let textField = UITextField()
//            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
//            textField.leftViewMode = .always
////            textField.backgroundColor = .black
//        textField.textColor = .white
//        textField.layer.shadowColor = UIColor.black.cgColor
//        textField.layer.shadowRadius = 3.0
//        textField.layer.shadowOpacity = 1.0
//        textField.layer.shadowOffset = CGSize(width: 4, height: 4)
//        textField.font = .systemFont(ofSize: 27, weight: .bold)
//            return textField
//        }()
//
////
////    private var pickerView: UIPickerView = {
////        let picker = UIPickerView()
////        picker.isHidden = true
////        return picker
////    }()
//
//    private var scrollView: UIScrollView = {
//        let scroll = UIScrollView()
//        scroll.isUserInteractionEnabled = true
//        return scroll
//    }()
//
//
//    private let collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumInteritemSpacing = 3
//        layout.minimumLineSpacing = 5
//        layout.itemSize = CGSize(width: 400, height: 300)
//        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .systemBackground
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.register(FiltersCollectionViewCell.self,
//                                forCellWithReuseIdentifier: FiltersCollectionViewCell.identifier)
//        return collectionView
//    }()
//
//
//    private let privacyButtonItem: UIButton = {
//        let barButton = UIButton()
//        barButton.setImage(UIImage(systemName: "lock.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
//        barButton.tintColor = .black
//        return barButton
//    }()
//
//
//
//    private let peopleInvitedButton: UIButton = {
//        let barButton = UIButton()
//        barButton.setImage(UIImage(systemName: "person.2.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
//        barButton.tintColor = .black
//        return barButton
//    }()
//
//    private var peopleCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumInteritemSpacing = 3
//        layout.minimumLineSpacing = 0
//        layout.itemSize = CGSize(width: 100, height: 100)
//        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .none
//        collectionView.layer.cornerRadius = 8
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.register(AddUsersToLinkCollectionViewCell.self,
//                                forCellWithReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier)
//        return collectionView
//    }()
//
//
//    private let locationImageView: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(systemName: "mappin.and.ellipse")
//        iv.tintColor = .black
//        return iv
//    }()
//
//    private let locationTypeTextField: UITextField = {
//        let textField = UITextField()
//        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
//        textField.leftViewMode = .always
//        textField.backgroundColor = .systemBackground
//        textField.placeholder = "Enter Location"
//        textField.font = .systemFont(ofSize: 21, weight: .medium)
//        return textField
//    }()
//
//
//    private let infoLabel: UILabel = {
//        let label = UILabel()
//        label.text = "EVENT INFORMATION"
//        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
//        label.textAlignment = .center
//        label.textColor = .white
//        label.layer.masksToBounds = true
//        label.layer.cornerRadius = 10
//        label.backgroundColor = .black
//        return label
//    }()
//
//    private let locationLabel: UILabel = {
//        let label = UILabel()
//        label.text = "LOCATION"
//        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
//        label.textAlignment = .left
//        label.textColor = myPurple
//        label.layer.masksToBounds = true
//        label.layer.cornerRadius = 10
////        label.backgroundColor = .black
//        return label
//    }()
//
//    private let dateLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Date"
//        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
//        label.textAlignment = .left
//        label.textColor = myPurple
//        return label
//    }()
//
//    private let backView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .black
//        view.layer.masksToBounds = true
//        view.layer.cornerRadius = 20
//        return view
//    }()
//
//
//    private let infoTextField: UITextView = {
//        let textField = UITextView()
//        textField.backgroundColor = .systemBackground
//        textField.textColor = .black
//        textField.layer.borderColor = UIColor.black.cgColor
//        textField.layer.borderWidth = 1
//        textField.font = .systemFont(ofSize: 21, weight: .regular)
//        textField.layer.cornerRadius = 8
//        return textField
//    }()
//
//    private let calenderImageView: UIImageView = {
//        let iv = UIImageView()
//        iv.isUserInteractionEnabled = true
//        iv.image = UIImage(systemName: "calendar", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
//        iv.tintColor = .white
//        return iv
//    }()
//
//
//    private let datePicker: UIDatePicker = {
//        let datePicker = UIDatePicker()
////        datePicker.countDownDuration = TimeInterval()
//        datePicker.preferredDatePickerStyle = .wheels
////        datePicker.isSelected = true
//        datePicker.backgroundColor = .white
//        return datePicker
//    }()
//
//    private let tableIdentifier = "tableCell"
//
//    private let tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.register(CreateLinkTableViewCell.self, forCellReuseIdentifier: CreateLinkTableViewCell.identifier)
//
//        return tableView
//    }()
//
//
//    private let infoButton:  UIButton = {
//        let button = UIButton()
//        button.setTitle("Information", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        return button
//    }()
//
//    private let invitedGuestButton:  UIButton = {
//        let button = UIButton()
//        button.setTitle("People Invited", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        return button
//    }()
//
//
//    //MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//        configureNav()
//        addCustomAnnotation()
//        mapView.delegate = self
//        view.addSubview(scrollView)
//        scrollView.addSubview(tableView)
////        scrollView.addSubview(mainImageView)
//        scrollView.addSubview(collectionView)
//        scrollView.addSubview(linkTypeImage)
//        scrollView.addSubview(linkTypeTextField)
//        scrollView.addSubview(privacyButtonItem)
////        scrollView.insertSubview(pickerView, at: 2)
//        scrollView.addSubview(locationImageView)
//        scrollView.addSubview(peopleInvitedButton)
//        scrollView.addSubview(peopleCollectionView)
//        scrollView.addSubview(locationImageView)
//        scrollView.addSubview(mapView)
//        scrollView.addSubview(locationTypeTextField)
////        scrollView.addSubview(infoLabel)
////        scrollView.addSubview(infoTextField)
//        scrollView.addSubview(datePicker)
//        scrollView.addSubview(calenderImageView)
//        scrollView.addSubview(captionImage)
////        scrollView.addSubview(captionTextField)
//        scrollView.addSubview(dateLabel)
//        scrollView.addSubview(locationLabel)
//        scrollView.insertSubview(backView, at: 0)
//        scrollView.contentSize = CGSize(width: (view.width), height: (1200))
////        pickerView.delegate = self
////        pickerView.dataSource = self
//        peopleCollectionView.delegate = self
//        peopleCollectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.dataSource = self
////        linkTypeTextField.delegate = self
//        linkTypeTextField.text = typeOfLink
//        linkTypeImage.image = iconImage
//        dateChanged(datePicker)
////        scrollView.addSubview(infoButton)
//        scrollView.addSubview(invitedGuestButton)
//        tableView.delegate = self
//        tableView.dataSource = self
//
//
//        peopleInvitedButton.addTarget(self, action: #selector(didTapPeopleButton), for: .touchUpInside)
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
//        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapCalendar))
//        linkTypeImage.addGestureRecognizer(tap)
//        calenderImageView.addGestureRecognizer(tap2)
//
//
//
//        privacyButtonItem.addTarget(self, action: #selector(didTapLock), for: .touchUpInside)
//
//
//
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        locationTypeTextField.text = self.locationTitle
//    }
//
//
//
//    //MARK: - Init
//
//    init(arrayOfImage: [UIImage], locationTitle: String?, coordinates: CLLocationCoordinate2D?, results: [SearchResult], typeOfLink: String, iconImage: UIImage, caption: String) {
//        self.arrayOfImage = arrayOfImage
//        self.locationTitle = locationTitle
//        self.coordinates = coordinates
//        self.resultsArray = results
//        self.typeOfLink = typeOfLink
//        self.iconImage = iconImage
//        self.caption = caption
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    //MARK: - LayoutSubviews
//
//    override func viewDidLayoutSubviews() {
//        scrollView.frame = view.bounds
//        collectionView.frame = CGRect(x: 15, y: 20, width: view.width-30, height: 300)
//        linkTypeImage.frame = CGRect(x: collectionView.left+20, y: collectionView.bottom-70, width: 60, height: 60)
//        linkTypeTextField.frame = CGRect(x: linkTypeImage.right+10, y: collectionView.bottom-70, width: view.width-linkTypeImage.width-20, height: 50)
//
//        tableView.frame = CGRect(x: 0,
//                                 y: collectionView.bottom+20,
//                                 width: view.width,
//                                 height: 50)
//
//        captionImage.frame = CGRect(x: 15,
//                                    y: tableView.bottom+20,
//                                    width: 40,
//                                    height: 40)
//        captionTextField.frame = CGRect(x: captionImage.right+10, y: tableView.bottom+20, width:  view.width-captionImage.width-50, height: 50)
//
//
//        peopleCollectionView.frame = CGRect(x: 15, y: captionTextField.bottom, width: view.width-peopleInvitedButton.width-30, height: 130)
//        locationLabel.frame = CGRect(x: 15, y: peopleCollectionView.bottom+20, width: view.width-30, height: 40)
//        privacyButtonItem.frame = CGRect(x: view.width-30-15, y: peopleCollectionView.bottom+20, width: 30, height: 30)
//
//        mapView.frame = CGRect(x: 15, y: locationLabel.bottom+10, width: view.width-30, height: 200)
//
//        locationTypeTextField.frame = CGRect(x: 15, y: mapView.bottom+10 , width: view.width-locationImageView.width-privacyButtonItem.width-60, height: 50)
//
//        dateLabel.frame = CGRect(x: 15, y: locationTypeTextField.bottom+20, width: view.width-30, height: 40)
//
//        datePicker.frame = CGRect(x: 15, y: dateLabel.bottom+10, width: view.width-30 , height: 200)
//
//
//        infoLabel.frame = CGRect(x: 15, y: datePicker.bottom+20, width: view.width-30, height: 40)
//        infoTextField.frame = CGRect(x: 15, y: infoLabel.bottom+10, width: view.width-30, height: 150)
//
//    }
//    //MARK: - Actions
//
//
//   private func configureNav() {
//
//        navigationController?.navigationBar.prefersLargeTitles = false
//
//        navigationController?.navigationBar.isHidden = false
//        view.backgroundColor = .systemBackground
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = .clear
//
//        navigationItem.rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
//    }
//
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard !(annotation is MKUserLocation) else {
//            return nil
//        }
//
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: mapIdentifier)
//
//        if annotationView == nil {
//            //create the view
//
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: mapIdentifier)
//
//        } else {
//            annotationView?.annotation = annotation
//        }
//
//        mapTypeImage.image = iconImage
//        annotationView?.addSubview(mapTypeImage)
//
//        return annotationView
//    }
//
//
//    func addCustomAnnotation() {
//
//
//        guard let coordinates = self.coordinates else {
//            return
//        }
//        let pin  = MKPointAnnotation()
//        pin.coordinate = coordinates
//        self.mapView.addAnnotation(pin)
//        print("Created a new pin!")
//    }
//
//
//    @objc private func didTapDone() {
//
//        infoTextField.resignFirstResponder()
//        let extraInfo = infoTextField.text ?? ""
//        let info = captionTextField.text ?? ""
//
//        // Generate post ID
//        guard let newPostID = createNewPostID(),
//              let stringDate = String.date(from: Date())
//        else {
//            return
//        }
//
//        guard let username = UserDefaults.standard.string(forKey: "username"),
//              let locationTitle = self.locationTitle,
//              let coordinates = self.coordinates,
//              let linkTypeName = linkTypeTextField.text,
//              let dateOfLink = self.postDateString else {
//            return
//        }
//
//        let latitude = coordinates.latitude
//        let longitude = coordinates.longitude
//
//        // Upload Post
//        StorageManager.shared.uploadLinkPost(
//            data: arrayOfImage[0].pngData(),
////            data: image.pngData(),
//            id: newPostID
//        ) { newLinkPostDownloadURL in
//            guard let postLinkUrl = newLinkPostDownloadURL else {
//                print("error: failed to upload")
//                return
//            }
//
//            StorageManager.shared.uploadLinkTypeImage(
//                data: self.linkTypeImage.image?.pngData(),
//                id: newPostID) { (url) in
//                guard let linkTypeImageDownloadURL = url else {
//                    print("error: failed to upload")
//                    return
//                }
//
//            // New Post
//            let newLink = LinkModel(
//                id: newPostID,
//                user: username,
//                info: info,
//                location: Coordinates(latitude: latitude, longitude: longitude),
//                locationTitle: locationTitle,
//                linkTypeName: linkTypeName,
//                invites: self.resultsArray,
//                postedDate: stringDate,
//                linkDate: dateOfLink,
//                postUrl: postLinkUrl,
//                likers: [],
//                isPrivate: self.isLocked,
//                linkTypeImage: linkTypeImageDownloadURL.absoluteString,
//                extraInformation: extraInfo)
//
//            // Update Database
//            DatabaseManager.shared.createLink(newLink: newLink) { [weak self] finished in
//                guard finished else {
//                    return
//                }
//                DispatchQueue.main.async {
//                    self?.tabBarController?.tabBar.isHidden = false
//                    self?.tabBarController?.selectedIndex = 0
//                    self?.navigationController?.popToRootViewController(animated: false)
//
//                    NotificationCenter.default.post(name: .didPostNotification,
//                                                    object: nil)
//                }
//            }
//            }
//        }
//
//    }
//
//    private func createNewPostID() -> String? {
//        let timeStamp = Date().timeIntervalSince1970
//        let randomNumber = Int.random(in: 0...1000)
//        guard let username = UserDefaults.standard.string(forKey: "username") else {
//            return nil
//        }
//
//        return "link_\(username)_\(randomNumber)_\(timeStamp)"
//    }
//    @objc private func didTapCalendar() {
////        datePicker.isSelected = true
//
//        if !datePicker.isHidden {
//            datePicker.isHidden = true
//
//          //Hide the calendar here
//
//         }
//         else {
//            datePicker.isHidden = false
//
//          // Show the Calendar Here
//         }
//
////        self.view.endEditing
//        print("Did Tap Calender ")
//
//    }
//
//
//
//    @objc private func didTapPeopleButton() {
//        print("did tap people button")
//
////        let vc = AddNewPeopleToLinkViewController()
////        vc.completion = { [weak self] result in
////            guard let strongSelf = self else {return}
////            strongSelf.resultsArray.append(contentsOf: result)
////            strongSelf.peopleCollectionView.reloadData()
////            print("results array: \(strongSelf.resultsArray)")
////    }
////
////        let navVC = UINavigationController(rootViewController: vc)
////        present(navVC, animated: true)
//    }
//
//    @objc private func didTapImage() {
//        let actionSheet = UIAlertController(title: "Attach Photo",
//                                            message: "Where would you like to attach a photo from",
//                                            preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
//
//            let picker = UIImagePickerController()
//            picker.sourceType = .camera
//            picker.delegate = self
//            picker.allowsEditing = true
//            self?.present(picker, animated: true)
//
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
//
//            let picker = UIImagePickerController()
//            picker.sourceType = .photoLibrary
//            picker.delegate = self
//            picker.allowsEditing = true
//            self?.present(picker, animated: true)
//
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        present(actionSheet, animated: true)
//    }
//
//    @objc private func didTapLock() {
//        isLocked = !isLocked
//
//        if isLocked {
//            privacyButtonItem.setImage( UIImage(systemName: "lock.open.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
//
//            print(isLocked)
//        } else {
//            privacyButtonItem.setImage(UIImage(systemName: "lock.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
//            print(isLocked)
//        }
//    }
//
//    func dateChanged(_ sender: UIDatePicker) {
//
//
//        let date = sender.date
//        let postDateString = DateFormatter.formatter.string(from: date)
//        self.postDateString = postDateString
//
//
//
//
////        let postDateString = Strin
////        let postDateString = String.date(from: sender.date)
////
////        let dateFormatter = NSDateFormatter()
////           dateFormatter.dateFormat = "MMM dd, YYYY"
////           let somedateString = dateFormatter.stringFromDate(sender.date)
//
//
//        print("The string: \(postDateString)")
//
//    }
//
//}
//
//extension CreateLinkViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true, completion: nil)
//        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
//            return
//        }
//        linkTypeImage.image = image
//    }
//}
//
//
//
//
//
//extension CreateLinkViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == peopleCollectionView {
//            return resultsArray.count
//        } else {
//            return arrayOfImage.count
//        }
//        //viewModels.count
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//
//        if collectionView == peopleCollectionView {
//            let model = resultsArray[indexPath.row]
//            guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier,
//                    for: indexPath
//            ) as? AddUsersToLinkCollectionViewCell else {
//                fatalError()
//            }
//            cell.configure(with: model)
//            return cell
//        } else {
//            let image = arrayOfImage[indexPath.row]
//            guard let cell = collectionView.dequeueReusableCell(
//                    withReuseIdentifier: FiltersCollectionViewCell.identifier,
//                    for: indexPath
//            ) as? FiltersCollectionViewCell else {
//                fatalError()
//            }
//            cell.configure(with: image)
//            return cell
//        }
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100, height: 100)
//    }
//
//}
//
////extension CreateLinkViewController: UIPickerViewDelegate, UIPickerViewDataSource {
////
////    func numberOfComponents(in pickerView: UIPickerView) -> Int {
////        return 1
////    }
////
////    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
////        return typeofLinkArray.count
////    }
////
////    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
////        return typeofLinkArray[row]
////    }
////
////    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
////        self.linkTypeTextField.isHidden = false
////        self.pickerView.isHidden = true
////         self.linkTypeTextField.text = typeofLinkArray[row]
////    }
////
////}
//
////extension CreateLinkViewController: UITextFieldDelegate {
////
////    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
////        self.linkTypeTextField.isHidden = true
////         self.pickerView.isHidden = false
////         return false
////    }
////}
//
//
//
//
//extension CreateLinkViewController: UITableViewDelegate, UITableViewDataSource {
//
//
//
//
//    ///Sections
////    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
////        return tableSections[section].title
////    }
////    func numberOfSections(in tableView: UITableView) -> Int {
////        tableSections.count
////    }
//
//
//    /// Cells
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: CreateLinkTableViewCell.identifier, for: indexPath) as? CreateLinkTableViewCell else {
//            fatalError()
//        }
////        let section = tableSections[indexPath.section]
////        cell.size(CGSize(width: view.width, height: 400))
//        cell.contentView.addSubview(infoButton)
////        cell.configure(with: section.data)
//        return cell
//
//    }
//
//
//
//}
