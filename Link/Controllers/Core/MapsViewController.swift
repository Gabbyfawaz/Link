//
//  ViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 01/02/2022.
//

import UIKit
import CoreLocation
import MapKit
import SDWebImage
import UberRides


class MyAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var image : UIImage?
    var index: Int
    var offset: Int


    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, index: Int, image: UIImage, offset: Int) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.index = index
        self.image = image
        self.offset = offset
        super.init()
    }
}


class BoomingAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    @objc dynamic var coordinate: CLLocationCoordinate2D

    var index: Int
    var people: [SearchUser]


    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, people: [SearchUser], index: Int) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.index = index
        self.people = people
        super.init()
    }
}

class MyPinAnnotations: MKPointAnnotation {
   
    override init() {
        super.init()
    }
}


class MapsViewController: UIViewController {
    
    // MARK: Properties
    
    private var index = 0
    private var boomingIndex = 0
    private var boomingPins = [Pin?]()
    private var boomingView = BoomingView()
    private let mapIdentifier = "mapidentifier"
    private let manager = CLLocationManager()
    private var allLinks: [(link: LinkModel, owner: String)] = []
    private var observer: NSObjectProtocol?
    private var pinObserver: NSObjectProtocol?
    private var longitude: CLLocationDegrees?
    private var latitude: CLLocationDegrees?
    private var usersLocationTitle: String?
    static var boomingPin: Pin?
    private var quickLinks: [(quickLinks: [QuickLink], owner: String)] = []

    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.overrideUserInterfaceStyle = .light
        return map
    }()
    
    private var quickLinkCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 140, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(StoryCollectionViewCell.self,
                                forCellWithReuseIdentifier: StoryCollectionViewCell.identifier)
//        collectionView.layer.cornerRadius = 10
//        collectionView.layer.masksToBounds = true
        return collectionView
    }()
    
    
   
    
    private let linkButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "link", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)),
                        for: .normal)
//        button.setTitle("Quick", for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let pinButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "pin.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)),
                        for: .normal)
//        button.setTitle("Quick", for: .normal)
        button.tintColor = .black
        return button
    }()
    
    
    private let menuButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "list.bullet", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)),
                        for: .normal)
//        button.setTitle("Quick", for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private var  stackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.layer.cornerRadius = 5
//        stack.backgroundColor = UIColor(white: 0, alpha: 0.7)
        return stack
    }()
    
    

    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        AuthManager.shared.signOut { sucess in
//            //
//        }

        getCurrentLocation()
        configureNavigationBar()
        registerMapAnnotationViews()
        boomingView.delegate = self
        mapView.delegate = self
        view.addSubview(mapView)
        view.addSubview(quickLinkCollectionView)
        view.addSubview(menuButton)
        quickLinkCollectionView.delegate = self
        quickLinkCollectionView.dataSource = self
        view.addSubview(stackView)
        stackView.addArrangedSubview(linkButton)
        stackView.addArrangedSubview(pinButton)
//        DatabaseManager.shared.deleteLinkAfterEventComplete()
     
        fetchAllLinks()
        

//        fetchPinFromDatabase()
        observer = NotificationCenter.default.addObserver(
                    forName: .didPostLinkOnMap,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                   // remove all annotations
                    guard var allAnnotations = self?.mapView.annotations  else {
                        fatalError()
                    }
                    allAnnotations.removeAll()
                    self?.fetchAllLinks()
//                    self?.fetchPinFromDatabase()
                }
        
        pinObserver = NotificationCenter.default.addObserver(
            forName: .didUpdatePins,
            object: nil,
            queue: .main
        ) { [weak self] _ in
           // remove all annotations
            self?.fetchPinFromDatabase()
//                    self?.fetchPinFromDatabase()
        }
               
        
    }
    
    // MARK: Layout Subviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
//        mapView.frame = view.bounds
        mapView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.height-view.safeAreaInsets.bottom
        )
        quickLinkCollectionView.frame = CGRect(x: 5,
                                           y: mapView.bottom-60,
                                           width: view.width-10,
                                           height: 60)
//       cz,m
//        menuButton.frame = CGRect(x: view.width-50,
//                                  y: view.safeAreaInsets.top,
//                                  width: 30,
//                                  height: 30)
    }
    
    // MARK: Actions

    private func configureNavigationBar() {


        let titleLabel = UILabel()
        titleLabel.text = "LINK"
        titleLabel.textColor = UIColor.black
        titleLabel.font = .systemFont(ofSize: 30, weight: .semibold)
        let leftItem = UIBarButtonItem(customView: titleLabel)
        view.backgroundColor = .black
        self.navigationItem.leftBarButtonItem = leftItem
        tabBarController?.tabBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "paperplane.fill"), style: .done, target: self, action: #selector(didTapMessage)),
            UIBarButtonItem(image: UIImage(systemName: "mappin.and.ellipse"), style: .done, target: self, action: #selector(didTapLocation)),
            UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21)), style: .done, target: self, action: #selector(didTapAdd))]
        
        
    }
    
    //MARK: - NavigationBarActions
    
    @objc func boomingPinDisplay() {
        
    }
    
    @objc func mainEventDisplay() {
        
    }
    
    @objc func didTapMessage() {
        
        tabBarController?.tabBar.isHidden = true
        let vc = ConversationsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapAdd() {
        tabBarController?.tabBar.isHidden = true
        let vc = LinkCameraViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func didTapLocation() {
        
        let vc =  SearchPinResultTableViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
//        navigationController?.pushViewController(vc, animated: true)
        present(navVC, animated: true, completion: nil)
        
        
    }
    
    
    func getCurrentLocation() {
            // Ask for Authorisation from the User.
            self.manager.requestAlwaysAuthorization()

            // For use in foreground
            self.manager.requestWhenInUseAuthorization()

            if CLLocationManager.locationServicesEnabled() {
                manager.delegate = self
                manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                manager.requestLocation()
            }
        }
    
    
    private func registerMapAnnotationViews() {
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(MyAnnotation.self))
        mapView.register(BoomingAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(BoomingAnnotation.self))
    }
    

    
    
      func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage {
          UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
          image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
          let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
          UIGraphicsEndImageContext()
          return newImage
      }

    
    
    

    //MARK: - Pin Location
    
    func fetchPinFromDatabase() {
//        boomingView.delegate = self
        var index = 0
        DatabaseManager.shared.getBoomingPin { pins in
            self.boomingPins = pins
            pins.forEach { pin in
               
                guard let latitude  = pin?.cooordinates.latitude,
                      let longitude = pin?.cooordinates.longitude,
//                      let locationTitle = pin?.locationString,
                        let people = pin?.people else
                      {
                          return
                      }
                let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                

                
                let pinAnnotation = BoomingAnnotation(title: "", subtitle: "It's Booming", coordinate: coordinates, people: people ,index: index)
                print("pin annotation: \(index)")
            
                self.mapView.addAnnotation(pinAnnotation)
                index += 1
            }
        }
    }
    
    
    
    
    //MARK: - Fetch All Links
   
    private func createUniqueAnnotation(linkType: String, linkInfo: String, linkTypeImage: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, linkId: String, index: Int) {
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        DispatchQueue.global(qos: .background).async {
        
        
            guard let url = URL(string: linkTypeImage) else {
                return
            }
            print("the url:\(url)")
                if let imageData = try? Data(contentsOf: url) {
                    
                    DispatchQueue.main.async {
                        guard let image: UIImage = UIImage(data: imageData) else {
                            fatalError()
                        }
                        print("The index id: \(index)")
                      
                        let annotation = MyAnnotation(title: linkType, subtitle: linkInfo, coordinate: coordinates, index: index, image: image, offset: 0)
                        self.mapView.addAnnotation(annotation)
                }
            
        }
            
        }
    
    }
    
 
       private func fetchAllLinks() {
           
           guard let username = UserDefaults.standard.string(forKey: "username") else {
               return
               
           }
           
           let userGroup = DispatchGroup()
           let otherGroup = DispatchGroup()
           let thirdGroup = DispatchGroup()
           userGroup.enter()

           var allLinks: [(link: LinkModel, owner: String)] = []
           var quickLinks: [(quickLinks: [QuickLink], owner: String)] = []
           DatabaseManager.shared.following(for: username) { usernames in
               defer {
                   userGroup.leave()
               }

              
               let users = usernames + [username]
               print("the users: \(users)")
               for current in users {
                   
                   otherGroup.enter()
                   
                   DatabaseManager.shared.getAllQuickLinks(for: current) { results in
                       defer {
                           otherGroup.leave()
                       }
                       switch results {
                       case .success(let data):

                           if data.count != 0 {
                               quickLinks.append((quickLinks: data, owner: current))
                               self.quickLinks = quickLinks
                               self.quickLinkCollectionView.reloadData()
                           }
                        
                       case .failure(let error):
                           print("this has been an error geting quickLink: \(error.localizedDescription)")
                       }
                   
                   thirdGroup.enter()
                   DatabaseManager.shared.getAllLinks(for: current) { result in
                       defer {
                           thirdGroup.leave()
                       }
                       print("All result: \(result)")
                          
                           switch result {
                           case .success(let links):
                               print("case links: \(links)")
                               allLinks.append(contentsOf: links.compactMap({
                                   (link: $0, owner: current)
                               }))
                               
                               
                               var index = 0
                               userGroup.notify(queue: .main) {
                                   otherGroup.notify(queue: .main) {
                                   thirdGroup.notify(queue: .main) {
                                   self.allLinks = allLinks
                                   allLinks.forEach { model in

                                   guard let latitude = model.link.location.latitude, let longitude = model.link.location.longitude else {
                                       return
                                   }

                                    DispatchQueue.main.async {
                                      
                                       self.quickLinkCollectionView.reloadData()
                                       self.createUniqueAnnotation(
                                           linkType: model.link.linkTypeName,
                                           linkInfo: model.link.info,
                                           linkTypeImage: model.link.linkTypeImage,
                                           latitude: latitude,
                                           longitude: longitude,
                                           linkId: model.link.id,
                                           index: index)
                                        self.fetchPinFromDatabase()
                                        index += 1
                                       }
                                   }

                               }
                              }
                               }
                           case .failure:
                               break
                           }
                       }
               }
                   
                   }
               }
           }


       }
       
    
    

 // MARK: Location Manager delegate
extension MapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    
        guard let latitude = locations.last?.coordinate.latitude, let longitude = locations.last?.coordinate.longitude else {
            return
        }
        
        self.latitude = latitude
        self.longitude = longitude
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        mapView.setRegion(region, animated: true)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { (placemarks, error) in
            if error != nil {
                print("something went horribly wrong")
            }
            if let placemarks = placemarks {
                self.usersLocationTitle = placemarks.first?.name
            }
        }
        
       
      
      
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting current location: \(error)")
    }
}

extension MapsViewController: MKMapViewDelegate {
    
  
     
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        // This illustrates how to detect which annotation type was tapped on for its callout.
        if let annotation = view.annotation as? MyAnnotation {
           let index = annotation.index
            
                let linkModel = allLinks[index].link
                let username = allLinks[index].owner
            
                let vc = EventViewController(link: linkModel, owner: username)
                navigationController?.modalPresentationStyle = .automatic
                present(vc, animated: true, completion: nil)
        }
        
    }

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? BoomingAnnotation {
            
            let index = annotation.index
          
//            let coordinate = annotation.coordinate
//            guard let text = boomingPin?.locationString, let people = boomingPin?.people else {
//                return
//            }
            
            guard let boomingPin = self.boomingPins[index] else {
                return 
            }
            
//            completionHandler?(boomingPin)
            
//            MapsViewController.boomingPin = boomingPin
//            let dict = boomingPin.asDictionary()
//            boomingView.delegate = self
            NotificationCenter.default.post(name: .didTapPin, object: nil, userInfo: ["dict": boomingPin])
            
            boomingView.configure(pin: boomingPin)
            
        }

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        


        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKAnnotationView?
        if let annotation = annotation as? MyAnnotation {
            annotationView = setupAnnotationView(for: annotation, on: mapView)
        }else if let annotation = annotation as? BoomingAnnotation {
            annotationView = setupBoomingPinAnnotationView(for: annotation, on: mapView)
        }
        return annotationView
        
    }
    
    private func setupAnnotationView(for annotation: MyAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        
        let reuseIdentifier = NSStringFromClass(MyAnnotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
         

        guard let image = annotation.image else {
            fatalError()
        }
        
        let resizeImage = imageWithImage(image: image, scaledToSize: CGSize(width: 40, height: 40))

        guard let finalImage = resizeImage.circularImage(20) else {
            fatalError()
        }
        
        view.canShowCallout = true
        let imageView: UIImageView = {
             let iv = UIImageView()
             iv.contentMode = .scaleAspectFill
             iv.layer.masksToBounds = true
             iv.layer.cornerRadius = 20
             iv.frame.size.width = 40
             iv.frame.size.height = 40
            iv.image = image
            iv.isUserInteractionEnabled = true
             return iv
         }()
        view.insertSubview(imageView, at: 0)
        view.image = finalImage
        let rightButton = UIButton(type: .detailDisclosure)
        rightButton.tintColor = .label
//        rightButton.addTarget(self, action: #selector(didTapDetailDisclosureButton), for: .touchUpInside)
        view.rightCalloutAccessoryView = rightButton
        let offset = CGPoint(x: annotation.offset, y: 0 )
        view.centerOffset = offset
        return view
        
    }
    
    
    /// Create an annotation view for the Ferry Building, and add an image to the callout.
    /// - Tag: CalloutImage
    private func setupBoomingPinAnnotationView(for annotation: BoomingAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let identifier = NSStringFromClass(BoomingAnnotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout = true
            markerAnnotationView.markerTintColor = UIColor.black
            markerAnnotationView.glyphTintColor = .systemYellow
//            markerAnnotationView.glyphText = "\(annotation.people.count)"
            markerAnnotationView.glyphText = "15"
            markerAnnotationView.displayPriority = .defaultHigh
            markerAnnotationView.subtitleVisibility = .visible

//

            
//            guard  let text = annotation.subtitle else {
//                fatalError()
//            }
//            let people = annotation.people
//
//            print("people: \(people) and \(text)")
//            boomingView.configure(locationString: text, people: people)
//            boomingView.delegate = self
            markerAnnotationView.detailCalloutAccessoryView = boomingView
           
        }
    
        return view
    }
}




extension MapsViewController: UICollectionViewDelegate, UICollectionViewDataSource, StoryCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quickLinks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = quickLinks[indexPath.row].owner
        print("The model: \(model)")
        print("This is the quick link yall: \(quickLinks)")
        guard let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.identifier, for: indexPath) as? StoryCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: model, index: indexPath.row)
        cell.delegate = self
        return cell
    }
    
    func storyCollectionViewCellDidTapView(_ cell: StoryCollectionViewCell, index: Int) {
        print("Did tap image here")
        
//        let quiclLinks = quickLinks[index].quickLinks
        let vc = QuickLinkViewController(quickLink: quickLinks, index: index)
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
        // you want to set up vc for story page 
    }
    
}


extension MapsViewController: QuickLinkViewControllerDelegate {
    func quickLinkViewControllerRefreshgLinks(_ vc: QuickLinkViewController) {
        fetchAllLinks()
    }
    
    
}

extension MapsViewController: BoomingViewDelegate {

    func boomingDidPin(_ view: BoomingView, coordinates: CLLocationCoordinate2D, locationTitle: String) {
        // add new user to database
        
        
    }
    
    
    func boomingViewDidTapUber(_ view: BoomingView, coordinates: CLLocationCoordinate2D, locationTitle: String) {
        
        guard let usersLatitude = self.latitude,
              let userLongitude = self.longitude,
              let usersLocationTitle = self.usersLocationTitle else {
                  return
              }
        
        let latitude2 = coordinates.latitude
        let longitude2 = coordinates.longitude

        let builder = RideParametersBuilder()
        let pickupLocation = CLLocation(latitude: usersLatitude, longitude: userLongitude)
        let dropoffLocation = CLLocation(latitude: latitude2, longitude: longitude2)
        builder.pickupNickname = usersLocationTitle
        builder.pickupLocation = pickupLocation
        builder.dropoffLocation = dropoffLocation
        builder.dropoffNickname = locationTitle
        builder.dropoffAddress = locationTitle
        let rideParameters = builder.build()

        let deeplink = RequestDeeplink(rideParameters: rideParameters, fallbackType: .appStore)
        deeplink.execute()
    
    }
    
    func boomingViewDidTapMaps(_ view: BoomingView, coordinates: CLLocationCoordinate2D, locationTitle: String) {
        //
    
        
            let regionDistance:CLLocationDistance = 10000
            let coordinates = coordinates
           let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(locationTitle)"
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    
}
