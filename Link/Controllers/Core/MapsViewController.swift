//
//  MapsViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/08/13.
//

import UIKit
import CoreLocation
import GoogleMaps
import SDWebImage


class MapsViewController: UIViewController, GMSMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    
    //MARK: - Properties

    private let manager = CLLocationManager()
    private var allLinks: [(link: LinkModel, owner: String)] = []
    private var observer: NSObjectProtocol?
    private var index = -1
    private var postIndex = 0
    private var allPins = [Pin]()
    private var viewModel = [LinkStory]()
    

    private let infoButton: UIButton = {
        let buttonButton = UIButton()
        buttonButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        buttonButton.tintColor = #colorLiteral(red: 0.2593106031, green: 0.06400629878, blue: 0.2692499161, alpha: 1)
        return buttonButton
    }()
    
    
    private let mainTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    private let subtitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 10, weight: .light)
        return label
    }()
    
    let viewModels = StoriesViewModel(stories: [
               Story(username: "jeffbezos", image: UIImage(named: "story1")),
               Story(username: "simon12", image: UIImage(named: "story2")),
               Story(username: "marqueesb", image: UIImage(named: "story3")),
               Story(username: "kyliejenner", image: UIImage(named: "story4")),
               Story(username: "drake", image: UIImage(named: "story5")),
           ])


    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: 120, height: 120)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(StoryCollectionViewCell.self,
                                forCellWithReuseIdentifier: StoryCollectionViewCell.identifier)
        return collectionView
    }()
    
    
    private var mapView: GMSMapView?
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apiKey = "AIzaSyC7B4xchyzZzmT0i6ymUE8AVBrgQ795vzk"
        GMSServices.provideAPIKey(apiKey)

        tabBarController?.tabBar.barTintColor = .black
        tabBarController?.tabBar.layer.cornerRadius =  0
        tabBarController?.tabBar.layer.masksToBounds = true
        getCurrentLocation()
        configureNavigationBar()
        view.insertSubview(collectionView, at: 1)
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchPinFromDatabase()
        fetchStories()
    
        
        fetchAllLinks()
        observer = NotificationCenter.default.addObserver(
            forName: .didPostLinkOnMap,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.allLinks.removeAll()
            self?.allPins.removeAll()
            self?.fetchAllLinks()
            self?.fetchPinFromDatabase()
        }
        
      

    
        infoButton.addTarget(self, action: #selector(didTapLinkInfo), for: .touchUpInside)
    
    }
    
    
    
    //MARK: - LayoutSubview
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = CGRect(x: 0,
                                      y: 80,
                                      width: view.width,
                                      height: 160)
    }
    
    
   //MARK: - GetCurrentLocation
    
    
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
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
      
        
        guard let latitude = locations.last?.coordinate.latitude, let longitude = locations.last?.coordinate.longitude else {
            return
        }
        
        // Create mapview and camera
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude , zoom: 3)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.delegate = self
        self.mapView = mapView
        self.view.insertSubview(mapView, at: 0)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting current location: \(error)")
    }
    
    //MARK: - Pin Location
    
    func fetchPinFromDatabase() {
        
        DatabaseManager.shared.getAllPins { (results) in
            switch results {
            
            case .success(let boomingPins):
                self.allPins = boomingPins
                print("The booming pins are: \(self.allPins)")
                self.addAllPins()
            case .failure(let error):
                print("Error fetching pins \(error)")
            }

        }

    }
    
    
    func addAllPins() {
        for boomingPin in self.allPins {
            let latitude = boomingPin.cooordinates.latitude
            let longitude = boomingPin.cooordinates.longitude
            
//            DispatchQueue.main.async {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            marker.title = boomingPin.name
            marker.snippet = "It's Booming Here"
            marker.map = self.mapView
//            }
        }
    }
    
    
    //MARK: - Fetch All Stories
    
    
    private func fetchStories() {
        
        var allStories: [LinkStory] = []
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
            
        }
        
        let group = DispatchGroup()
        
        DatabaseManager.shared.following(for: username) { usernames  in
       
            let users = usernames + [username]
            
            for current in users {
                group.enter()
                DatabaseManager.shared.getAllStories(for: current) { result in
                    DispatchQueue.main.async {
                        defer {
                            group.leave()
                        }

                        switch result {
                        case .success(let stories):
                            allStories.append(contentsOf: stories)
                        case .failure:
                            break
                        }
                    }
                }
   
            }
            
        }
            group.notify(queue: .main) {
                self.viewModel = allStories
                print("all stories: \(self.viewModel)")
                self.collectionView.reloadData()
        }
         
            

            
            
    }
    
    
 //MARK: - Fetch All Links
    
    private func fetchAllLinks() {
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
            
        }
        let userGroup = DispatchGroup()
        userGroup.enter()

        var allLinks: [(link: LinkModel, owner: String)] = []

        DatabaseManager.shared.following(for: username) { usernames in
            defer {
                userGroup.leave()
            }

            let users = usernames + [username]
            for current in users {
                userGroup.enter()
                DatabaseManager.shared.getAllLinks(for: current) { result in
                    DispatchQueue.main.async {
                        defer {
                            userGroup.leave()
                        }

                        switch result {
                        case .success(let links):
                            allLinks.append(contentsOf: links.compactMap({
                                (link: $0, owner: current)
                            }))

                        case .failure:
                            break
                        }
                    }
                }
            }
        }

        userGroup.notify(queue: .main) {
            let group = DispatchGroup()
            self.allLinks = allLinks
            print("allLinks: \(allLinks)")
            allLinks.forEach { model in
                group.enter()
            // add annotations
                
            guard let latitude = model.link.location.latitude, let longitude = model.link.location.longitude else {return}
                
                self.createUniqueAnnotation(
                    linkType: model.link.linkTypeName,
                    linkInfo: model.link.info,
                    linkTypeImage: model.link.linkTypeImage,
                    latitude: latitude,
                    longitude: longitude,
                    linkId: model.link.id)
                
                
            }

            group.notify(queue: .main) {
//                self.sortData()
//                self.LinkPostCollectionView?.reloadData()
            }
        }
    }
    
    
    //MARK: - Create Unique Annoation on Map
    
    
  
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
//        image.sd_roundedCornerImage(withRadius: 20, corners: .allCorners, borderWidth: 2, borderColor: .white)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    

    
    private func createUniqueAnnotation(linkType: String, linkInfo: String, linkTypeImage: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, linkId: String) {
        

        // create marker
        
        DispatchQueue.main.async {
            
            
            let url = URL(string: linkTypeImage)
              if let data = try? Data(contentsOf: url!)
              {
                self.index += 1
                let image: UIImage = UIImage(data: data) ?? UIImage(named: "maps")!
                let resizeImage = self.imageWithImage(image: image, scaledToSize: CGSize(width: 40, height: 40))
                
                let finalImage = resizeImage.circularImage(20)
                
                let marker = GMSMarker()
                marker.icon = finalImage
                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                marker.title = linkType
                marker.snippet = linkInfo
                marker.userData = self.index
                marker.map = self.mapView
                
            
              }
        
        }
      
    
                

        
        

        
    
        
    }

    

    

  //MARK: - Configure NavigationBar
    
    private func configureNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.text = "LINK"
        titleLabel.textColor = UIColor.black
        titleLabel.font = .systemFont(ofSize: 30, weight: .semibold)
        let leftItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
        
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
    
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "paperplane.fill"), style: .done, target: self, action: #selector(didTapMessage)),
            UIBarButtonItem(image: UIImage(systemName: "mappin.and.ellipse"), style: .done, target: self, action: #selector(didTapLocation)),
            UIBarButtonItem(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21)), style: .done, target: self, action: #selector(didTapAdd))]
      
        
    }
  
    
    
    //MARK: - NavigationBarActions
    
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
        
        let vc = PinLocationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
        
        
    }

    
    
    //MARK: - MapViewDelegate
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let customWindow = UIView()
        customWindow.frame = CGRect(x: 0,
                                    y: 0,
                                    width: 150,
                                    height: 50)
        customWindow.backgroundColor = .white
        customWindow.addSubview(infoButton)
        customWindow.addSubview(mainTitle)
        customWindow.addSubview(subtitle)
        
        infoButton.frame = CGRect(x: 110,
                                  y: 5,
                                  width: 40,
                                  height: 40)
        mainTitle.frame = CGRect(x: 5,
                                 y: 5,
                                 width: 110,
                                 height: 20)
        subtitle.frame = CGRect(x: 5,
                                y: 28,
                                width: 110,
                                height: 10)
        mainTitle.text =  marker.title
        subtitle.text = marker.snippet
        
        return customWindow
    }
    
    
    //MARK: - DidTapMarker
   
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let index = marker.userData as? Int else {return }
        print("The Index: \(index)")
        self.postIndex = index
        didTapLinkInfo()
        
    }
    
    
    @objc func didTapLinkInfo() {
        print("Did Tap Info")
        
        let index = self.postIndex
        
        let link = allLinks[index].link
        let user = allLinks[index].owner
        
        print("Link: \(link), User: \(user)")
        
        let vc = PostLinkViewController(link: link, owner: user)
        navigationController?.modalPresentationStyle = .automatic
        present(vc, animated: true, completion: nil)
        
        
    }
    
    //MARK: - CollectionViewDelegate/Datasource
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.stories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: StoryCollectionViewCell.identifier,
                for: indexPath
        ) as? StoryCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels.stories[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.height, height: collectionView.height)
    }


}

extension UIImage {
    func circularImage(_ radius: CGFloat) -> UIImage? {
        var imageView = UIImageView()
        if self.size.width > self.size.height {
            imageView.frame =  CGRect(x: 0, y: 0, width: self.size.width, height: self.size.width)
            imageView.image = self
            imageView.contentMode = .scaleAspectFit
        } else { imageView = UIImageView(image: self) }
        var layer: CALayer = CALayer()

        layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return roundedImage
    }
}




