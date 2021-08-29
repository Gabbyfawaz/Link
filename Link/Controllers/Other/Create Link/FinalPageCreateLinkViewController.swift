//
//  FinalPageCreateLinkViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/08/27.
//

import UIKit
import CoreLocation
import DateTimePicker


struct Sections {
    var sectionTitles: String
    var cellTitles: [String]
}

class FinalPageCreateLinkViewController: UIViewController {
    
    //MARK: - Properties
    
    private var id: [String]?
    private var arrayOfImage: [UIImage]
    private var iconImage: UIImage
    private var locationTitle: String?
    private var coordinates: CLLocationCoordinate2D?
    private var isLocked = false
    private var resultsArray = [SearchResult]()
    private var postDateString: String?
    private var typeOfLink: String
    private var caption: String
    private var tableSections = [
        Sections(sectionTitles: "Date", cellTitles: ["Date of Event"]),
        Sections(sectionTitles: "Go Back", cellTitles: ["Media", "Categories", "Location", "Guests"]),
        Sections(sectionTitles: "Promote Event", cellTitles: ["Sponsor Event", "Create Ticket"])
    ]
    
    
    private var linkTypeImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 35
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 2
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    
    private var typeOfLinkLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let eventInfoTextView: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = .secondarySystemBackground
        textField.textColor = .black
//        textField.layer.borderColor = UIColor.black.cgColor
//        textField.layer.borderWidth = 1
        textField.font = .systemFont(ofSize: 19, weight: .regular)
        textField.text = "Enter Event Information"
        return textField
    }()
    
    private let privacyButton: UIButton = {
        let barButton = UIButton()
        barButton.setImage(UIImage(systemName: "lock.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
        barButton.tintColor = .black
        return barButton
    }()
    
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    

//    let min = Date().addingTimeInterval(-60 * 60 * 24 * 4)
//    let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
//    let picker = DateTimePicker.create(minimumDate:  Date().addingTimeInterval(-60 * 60 * 24 * 4), maximumDate:  Date().addingTimeInterval(60 * 60 * 24 * 4))
    
    private let picker: UIDatePicker = {
        let  picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.isHidden = true
        picker.backgroundColor = .white
        picker.layer.cornerRadius = 10
        picker.layer.masksToBounds = true
        return picker
    }()
    
    let blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.effect = UIBlurEffect(style: .extraLight)
        view.isHidden = true
        return view
    }()
   
    

     
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        

        view.insertSubview(linkTypeImage, at: 0)
        view.insertSubview(typeOfLinkLabel, at: 0)
        view.insertSubview(eventInfoTextView, at: 0)
        view.insertSubview(tableView, at: 0)
        view.insertSubview(privacyButton, at: 0)
        view.insertSubview(picker, at: 6)
        view.insertSubview(blurEffectView, at: 5)
        
        linkTypeImage.image = iconImage
        typeOfLinkLabel.text = typeOfLink
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        privacyButton.addTarget(self, action: #selector(didTapLock), for: .touchUpInside)
        picker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        blurEffectView.addGestureRecognizer(tap)
        
        print("IDS: \(self.id)")
     

    }
    
    
    
    //MARK: - Init
    
    init(arrayOfImage: [UIImage], locationTitle: String?, coordinates: CLLocationCoordinate2D?, results: [SearchResult], typeOfLink: String, iconImage: UIImage, caption: String) {
        self.arrayOfImage = arrayOfImage
        self.locationTitle = locationTitle
        self.coordinates = coordinates
        self.resultsArray = results
        self.typeOfLink = typeOfLink
        self.iconImage = iconImage
        self.caption = caption
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        linkTypeImage.frame = CGRect(x: 15,
                                     y: 100,
                                    width: 70,
                                    height: 70)
        
        typeOfLinkLabel.frame = CGRect(x: linkTypeImage.right+20,
                                       y: 110,
                                       width: view.width-50-linkTypeImage.width-privacyButton.width,
                                    height: 30)
        
        privacyButton.frame = CGRect(x: typeOfLinkLabel.right+5,
                                       y: 110,
                                       width: 30,
                                    height: 30)

        eventInfoTextView.frame = CGRect(x: linkTypeImage.right+20,
                                         y: typeOfLinkLabel.bottom+10,
                                         width: view.width-50-linkTypeImage.width,
                                    height: 150)
        tableView.frame =  CGRect(x: 0,
                                  y: eventInfoTextView.bottom+20,
                                  width: view.width,
                                  height: 390)
        
        picker.frame = CGRect(x: (view.width-picker.width)/2, y:  (view.height-picker.height)/2, width: picker.width, height: picker.height)
        
    
    }
    
    //MARK: - Actions
    
    @objc private func didTapDone() {
        
        
        let extraInfo = eventInfoTextView.text ?? ""

        // Generate post ID
     
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let locationTitle = self.locationTitle,
              let coordinates = self.coordinates,
              let dateOfLink = self.postDateString,
              let newPostID = createNewPostID(),
              let newPostIDS = createNewPostIDS(),
              let stringDate = String.date(from: Date())
        else {
            return
        }
        
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude

        var dataImageArray = [Data]()
        arrayOfImage.forEach({ image in
            guard let dataImage = image.pngData() else {
                return
            }
            dataImageArray.append(dataImage)
        })
        print("Data: \(dataImageArray)")
        print("ids: \(newPostIDS)")
        // Upload Post
        StorageManager.shared.uploadLinkPosts(
            data:  dataImageArray,
//            data: image.pngData(),
            id: newPostID
        ) { newLinkPostDownloadURL in
            guard let postLinkUrl = newLinkPostDownloadURL else {
                print("error: failed to upload")
                return
            }
            
            print("Post Url: \(postLinkUrl)")
        var postLinkString = [String]()
            
            postLinkUrl.forEach({ url in
                
                let urlString = url.absoluteString
                postLinkString.append(urlString)
            })
        
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
                info: self.caption,
                location: Coordinates(latitude: latitude, longitude: longitude),
                locationTitle: locationTitle,
                linkTypeName: self.typeOfLink,
                invites: self.resultsArray,
                postedDate: stringDate,
                linkDate: dateOfLink,
                postArrayString: postLinkString,
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
    
    private func createNewPostIDS() -> [String]? {
        
        var idArray = [String]()
        let timeStamp = Date().timeIntervalSince1970
        let randomNumber = Int.random(in: 0...1000)
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return nil
        }
    
        arrayOfImage.forEach({ item in
            let id = "link_\(username)_\(randomNumber)_\(timeStamp)"
            idArray.append(id)
        })
        print("Print idArray: \(idArray)")
        return idArray

    }
    
    
    @objc private func didTapLock() {
        isLocked = !isLocked
        
        if isLocked {
            privacyButton.setImage( UIImage(systemName: "lock.open.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
            
            print(isLocked)
        } else {
            privacyButton.setImage(UIImage(systemName: "lock.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)), for: .normal)
            print(isLocked)
        }
    }
    
    
    @objc func didTapView() {
        picker.isHidden = true
        blurEffectView.isHidden = true
    }
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        
        let dateString = DateFormatter.formatter.string(from: picker.date)
        self.postDateString = dateString
        print("current: \(picker.date)")
       }
    
    

}


//MARK: - TableView Delegate/ Datasource

extension FinalPageCreateLinkViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSections[section].sectionTitles
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellTitles = tableSections[section].cellTitles
        return cellTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellTitles = tableSections[indexPath.section].cellTitles
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cellTitles[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellTitles = tableSections[indexPath.section].cellTitles
        
        switch cellTitles[indexPath.row] {
        case "Date of Event":
            blurEffectView.isHidden = false
            picker.isHidden = false
        case "Media":
            let vc = PostEditViewController(arrayOfImage: arrayOfImage)
            navigationController?.pushViewController(vc, animated: true)
        case "Categories":
            let vc = CategoryViewController(arrayOfImage: arrayOfImage, iconImage: iconImage, caption: caption)
            navigationController?.pushViewController(vc, animated: true)
        case "Location":
            let vc = LocationViewController(arrayOfImage: arrayOfImage, typeOfLink: typeOfLink, iconImage: iconImage, caption: caption)
            navigationController?.pushViewController(vc, animated: true)
        case "Guests":
            let vc = AddNewPeopleToLinkViewController(arrayOfImage: arrayOfImage, locationTitle: locationTitle, coordinates: coordinates, typeOfLink: typeOfLink, iconImage: iconImage, caption: caption)
            navigationController?.pushViewController(vc, animated: true)
        case "Sponsor Event":
            break
        case "Create Ticket":
            break
        default:
            break
        }
    }
    
}

//MARK: - TextView Delegate

extension FinalPageCreateLinkViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.becomeFirstResponder()
    }
    
}
