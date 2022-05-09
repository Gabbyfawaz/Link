//
//  QuickLinkViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 07/03/2022.
//

import UIKit
import SDWebImage
import FloatingPanel
import MapKit
import CoreLocation
import UberRides
import JGProgressHUD


protocol QuickLinkViewControllerDelegate: AnyObject {
    func quickLinkViewControllerRefreshgLinks(_ vc: QuickLinkViewController)
}
class QuickLinkViewController: UIViewController {
    
    //MARK: Properties
    private var observer: NSObjectProtocol?
    weak var delegate: QuickLinkViewControllerDelegate?
    private var indexRow = 0
    private var indexSection = 0
    private var quickLinks: [(quickLinks: [QuickLink], owner: String)]
    private let floatingPanel = FloatingPanelController()
    private let spinner = JGProgressHUD(style: .dark)
    private var isJoined = false
    private var isPinned = false
    private let locationManager = CLLocationManager()
    private var latitude: CLLocationDegrees?
    private var longitude: CLLocationDegrees?
    private var usersLocationTitle: String?
    public let textfield: UITextView = {
        let tf = UITextView()
        tf.text = "Link Title"
        tf.textAlignment = .left
        tf.textColor = .black
        tf.textAlignment = .center
        tf.backgroundColor = .white
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        tf.layer.cornerRadius = 10
        tf.clipsToBounds = true
        tf.isUserInteractionEnabled = false 
        return tf
    }()
    
    private var horizonatlstackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.backgroundColor = .black
        return stack
    }()
    private var  verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.backgroundColor = .white
        stack.layer.cornerRadius = 10
        return stack
    }()
    
    private let joinButton = LinkJoinButton()

    
    public let locationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    public let timeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "clock",withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    public let peopleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    private let customView = UIView()
  
    
    private var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemBackground
        return iv
        
    }()
    
    
    private var userProfileIcon: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 25
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    
    private var quickLinkSticker = QuickLinkSticker()
    
    private var progressView: UIProgressView = {
        var progress = UIProgressView()
        progress.tintColor = .systemYellow
        return progress
    }()
    

//    private var pinButton: UIButton = {
//        var button = UIButton()
//        button.setImage(UIImage(systemName: "pin.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)), for: .normal)
//        button.tintColor = .black
//        return button
//    }()
    
    //MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        configureUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        view.addSubview(userProfileIcon)
        view.addSubview(usernameLabel)
        view.addSubview(quickLinkSticker)
        view.addSubview(progressView)
        
        /// quick sticker
       
        view.addSubview(horizonatlstackView)
        horizonatlstackView.addArrangedSubview(locationButton)
        horizonatlstackView.addArrangedSubview(timeButton)
        horizonatlstackView.addArrangedSubview(peopleButton)
        view.addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(joinButton)
        verticalStackView.addArrangedSubview(horizonatlstackView)
        verticalStackView.addArrangedSubview(textfield)
       
        
        locationButton.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
        timeButton.addTarget(self, action: #selector(didTapTimeButton), for: .touchUpInside)
        peopleButton.addTarget(self, action: #selector(didTapPeopleButton), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(didTapJoinButton), for: .touchUpInside)
        
//        configureUI()
        getCurrentLocation()
       
//        quickLinkSticker.delegate = self
        
        configureNavBar("pin")
        view.backgroundColor = .black

        navigationController?.navigationBar.tintColor = .label
       
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapNext))
//        view.addGestureRecognizer(tap)
      
//        tap.cancelsTouchesInView = false
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(didTapCancel))
////        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(didTapCancel))
//        swipeDown.direction = .down
////        swipeUp.direction = .up
//
//        view.addGestureRecognizer(swipeDown)
//        view.addGestureRecognizer(swipeUp)
        
        locationButton.addTarget(self, action: #selector(didTapLocation) , for: .touchUpInside)
        
        
        let touchArea = CGSize(width: 80, height: self.view.frame.height)

           let leftView = UIView(frame: CGRect(origin: .zero, size: touchArea))
           let rightView = UIView(frame: CGRect(origin: CGPoint(x: self.view.frame.width - touchArea.width, y: 0), size: touchArea))

           leftView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftViewTapped)))
           rightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightViewTapped)))

           leftView.backgroundColor = .clear
           rightView.backgroundColor = .clear

           self.view.addSubview(leftView)
           self.view.addSubview(rightView)
        
    }
    
    //MARK: - Init
    
    init(quickLink: [(quickLinks: [QuickLink], owner: String)], index: Int) {
        self.quickLinks = quickLink
        self.indexSection = index
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    //MARK: Layout Subviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        usernameLabel.sizeToFit()
        imageView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        userProfileIcon.frame = CGRect(x: 10, y: 50, width: 50, height: 50)
        usernameLabel.frame = CGRect(x: userProfileIcon.right+10, y: 50, width: usernameLabel.width, height: 50)
        
//        maskImageView.frame = userProfileIcon.bounds
//        userProfileIcon.mask = maskImageView
        progressView.frame = CGRect(x: view.width-90-10, y: 100, width: 90, height: 20)

//        pinButton.frame = CGRect(x: 10, y: view.height-40-10, width: 30, height: 40)
//        quickLinkSticker.frame = CGRect(x: (view.width-160)/2, y: (view.height-105)/2, width: 160, height: 105)
        
//        quickLinkSticker.frame = CGRect(x: 50, y: 150, width: 160, height: 105)

       
    
    }

    //MARK: ACTIONS
    
    
    private func configureNavBar(_ nameOfPin: String) {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "multiply", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .black)), style: .done, target: self, action: #selector(didTapCancel)),
//           UIBarButtonItem(image: UIImage(systemName: nameOfPin, withConfiguration: UIImage.SymbolConfiguration(pointSize: 15)), style: .done, target: self, action: #selector(didTapPin))
        ]
    }
        
        
        @objc func didTapCancel() {
            
            delegate?.quickLinkViewControllerRefreshgLinks(self)
            let transition: CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromBottom
            self.view.window!.layer.add(transition, forKey: nil)
            self.dismiss(animated: true, completion: nil)
//            dismiss(animated: false, completion: nil)
            
        }
    
    
    @objc func leftViewTapped() {
        print("Left")
        
        
//        let maxCountSection = quickLinks.count-1
//        print("maxCount: \(maxCountSection)")
        let maxCountRow = quickLinks[indexSection].quickLinks.count-1
//
       
        
        if indexRow != 0 {
            indexRow -= 1
            configureUI()
        }
        
        if indexRow == 0 && indexSection != 0  {
            indexSection -= 1
            indexRow = maxCountRow
            configureUI()
        }
        
//        if indexRow <= 0 &&  indexSection <= 0 {
//            /// do nothing
//        }
        
    
        
    }
    
    @objc func rightViewTapped() {
        
        let finalIndex = indexRow + 1
        let maxCountSection = quickLinks.count-1
        print("maxCount: \(maxCountSection)")
        let maxCountRow = quickLinks[indexSection].quickLinks.count-1
        let maxCountRowOfArray = quickLinks[maxCountSection].quickLinks.count-1
        
        if indexRow < maxCountRow {
            indexRow += 1
            configureUI()
        }
        
        if indexRow == maxCountRow {
            if indexSection < maxCountSection {
                indexSection += 1
                 indexRow = 0
                configureUI()
            }
        
        }
        
       
        if finalIndex > maxCountRowOfArray {
            didTapCancel()
        }
        
        
//        if indexSection == maxCountSection && indexRow == maxCountRowOfArray {
//            didTapCancel()
//        }
        
        }
        
    
//
//    @objc func didTapPin() {
//
//        if isPinned {
//            let element = self.quickLinks.remove(at: self.indexSection)
//            quickLinks.insert(element, at: 0)
//           configureNavBar("pin.fill")
//        } else {
//            let element = self.quickLinks.remove(at: self.indexSection)
//            quickLinks.append(element)
//           configureNavBar("pin")
//        }
//
////
//
//
//    }
    
    
    @objc func didTapLocation() {
//        floatingPanel.move(to: .half, animated: true, completion: nil)
        let quickLink = quickLinks[indexSection].quickLinks[indexRow]
       
        guard let latitude = quickLink.locationCoodinates?.latitude,
              let longitude = quickLink.locationCoodinates?.longitude,
              let locationTitle = quickLink.locationTitle else {
                  let alert = UIAlertController(title: "No Location Set", message: "", preferredStyle: .alert)
                  alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                  present(alert, animated: true)
            return
        }
        
        
        
        let alert = UIAlertController(title: "Open", message: "Open Maps or Uber", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Maps", style: .default, handler: { _ in
            ///
        
                let regionDistance:CLLocationDistance = 10000
                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
                ]
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = "\(locationTitle)"
            mapItem.openInMaps(launchOptions: options)
        
        }))
        alert.addAction(UIAlertAction(title: "Uber", style: .default, handler: { _ in
            guard let latitude = quickLink.locationCoodinates?.latitude,
                  let longitude = quickLink.locationCoodinates?.longitude,
                  let locationTitle = quickLink.locationTitle,
                  let usersLatitude = self.latitude,
                  let userLongitude = self.longitude,
                  let usersLocationTitle = self.usersLocationTitle else {
                      return
                  }
            
            
            let builder = RideParametersBuilder()
            let pickupLocation = CLLocation(latitude: usersLatitude, longitude: userLongitude)
            let dropoffLocation = CLLocation(latitude: latitude, longitude: longitude)
            builder.pickupNickname = usersLocationTitle
            builder.pickupLocation = pickupLocation
            builder.dropoffLocation = dropoffLocation
            builder.dropoffNickname = locationTitle
            builder.dropoffAddress = locationTitle
            let rideParameters = builder.build()
            
            let deeplink = RequestDeeplink(rideParameters: rideParameters, fallbackType: .appStore)
            deeplink.execute()
        }))
        present(alert, animated: true)

    }
    
    @objc func didTapTimeButton() {
//        floatingPanel.move(to: .half, animated: true, completion: nil)
        
        guard let _ = quickLinks[indexSection].quickLinks[indexRow].timestamp else {
            let alert = UIAlertController(title: "No Date Set", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
//
        let alert = UIAlertController(title: "Add Reminder", message: "Save the date", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            // add alert to calender
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        present(alert, animated: true )
    }
    
    @objc func didTapPeopleButton() {
        floatingPanel.move(to: .half, animated: true, completion: nil)
    }
    
    
    @objc func didTapJoinButton() {
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        let user = SearchUser(name: username)
        observer = NotificationCenter.default.addObserver(forName: .didUpdateJoinButton, object: nil, queue: .main, using: { notification in
            let peopleJoining = notification.userInfo?.first?.value as? [SearchUser]
            let isJoined = peopleJoining?.contains(user)
            self.quickLinks[self.indexSection].quickLinks[self.indexRow].joined = peopleJoining ?? []
            self.isJoined = isJoined ?? false
            
            print("people joined: \(peopleJoining)")
        })
        
       
        isJoined = !isJoined
        joinButton.configure(for: isJoined ? .joined : .join)
//        spinner.show(in: view)
        let quickLink = quickLinks[indexSection].quickLinks[indexRow]
        DatabaseManager.shared.updateJoinState(state: isJoined ? .joined : .join, linkId: quickLink.id, owner: quickLink.username) { isSuccess in
            if isSuccess {
//                self.spinner.dismiss()
                print("Data Successful saved to database")
            }
        }
        
        
        


    }
    
    
    private func configureUI() {
        

//        imageView.image = nil
//        userProfileIcon.image = nil
//        usernameLabel.text = nil
//        progressView.progress = 0
        let quickLink = quickLinks[indexSection].quickLinks[indexRow]
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        let user = SearchUser(name: username)
        let joinedUser = quickLink.joined.contains(user)
        self.isJoined = joinedUser
        var profileURL: URL?
        StorageManager.shared.profilePictureURL(for: quickLink.username) { url in
            guard let usernameUrl = url else {
                return
            }
            
            profileURL = usernameUrl
            
        }
        
        guard let postUrl = URL(string: quickLink.imageUrlString!) else {
            return
        }
        
        DispatchQueue.main.async {
            self.usernameLabel.text = quickLink.username
            self.imageView.sd_setImage(with: postUrl, completed: nil)
            self.userProfileIcon.sd_setImage(with: profileURL, completed: nil)
            self.progressView.progress = Float(self.indexRow+1) / Float(self.quickLinks[self.indexSection].quickLinks.count)
            self.verticalStackView.isHidden = false
            self.textfield.text = quickLink.info
//            let newHieght = (quickLink.height+60)/2
            self.verticalStackView.frame = CGRect(x: quickLink.xPosition, y: quickLink.yPosition, width: 160, height: quickLink.height+60)
            self.setUpFloatingPanal(quickLink)
            self.joinButton.configure(for: self.isJoined ? .joined : .join)
            //                guard (quickLink.info != "") else {
            //                    self.verticalStackView.isHidden = true
            //                    self.floatingPanel.move(to: .hidden, animated: true, completion: nil)
            //                    return
            //                }
        }
    }
}


extension QuickLinkViewController: FloatingPanelControllerDelegate {
    private func setUpFloatingPanal(_ quickLink: QuickLink) {
        
        let appearance = SurfaceAppearance()

        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 40)
        shadow.radius = 40
        shadow.spread = 20
        appearance.shadows = [shadow]

        // Define corner radius and background color
        appearance.cornerRadius = 20
        appearance.backgroundColor = .clear

        
//        let floatingPanel = FloatingPanelController()
        floatingPanel.delegate = self // Optional
        
        
        let contentVC = ContentViewController(quickLink: quickLink)
        floatingPanel.set(contentViewController: contentVC)
//        floatingPanel.layout.initialState = .tip
        floatingPanel.addPanel(toParent: self)
        floatingPanel.move(to: .tip, animated: false, completion: nil)
        floatingPanel.surfaceView.appearance = appearance
        
    }
}





extension QuickLinkViewController: CLLocationManagerDelegate {
    //MARK: - MapViewFunctions
    
    
    func getCurrentLocation() {
            // Ask for Authorisation from the User.
            self.locationManager.requestAlwaysAuthorization()

            // For use in foreground
            self.locationManager.requestWhenInUseAuthorization()

            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.requestLocation()
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

       guard let latitude = locations.first?.coordinate.latitude,
             let longitude = locations.first?.coordinate.longitude else {
                 return
             }
        
        self.latitude = latitude
        self.longitude = longitude
        
        
        
        let coordinates = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(coordinates) { (placemarks, error) in
            if error != nil {
                print("something went horribly wrong")
            }
            if let placemarks = placemarks {
                self.usersLocationTitle = placemarks.first?.name
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }
}
