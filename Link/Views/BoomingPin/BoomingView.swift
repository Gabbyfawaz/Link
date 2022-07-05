//
//  BoomingView.swift
//  Link
//
//  Created by Gabriella Fawaz on 28/03/2022.
//


import UIKit
import CoreLocation

protocol BoomingViewDelegate: AnyObject {
    func boomingViewDidTapUber(_ view: BoomingView, coordinates: CLLocationCoordinate2D, locationTitle: String)
    func boomingViewDidTapMaps(_ view: BoomingView, coordinates: CLLocationCoordinate2D, locationTitle: String)
    func boomingDidPin(_ view: BoomingView, coordinates: CLLocationCoordinate2D, locationTitle: String)
}


class BoomingView: UIView {
    
    
//    static var people = [SearchUser]()
    
    private var observer: NSObjectProtocol?
    weak var delegate: BoomingViewDelegate?
//    private var locationString: String?
    private var pin: Pin?
    private var coordinates: CLLocationCoordinate2D?
    private var peopleJoining = [SearchUser]()
    
//    private var peopleJoining = [
//    SearchUser(name: "Josh"),
////    SearchUser(name: "jazmine"),
//    SearchUser(name: "tory"),
//    SearchUser(name: "olivia"),
//    SearchUser(name: "jamie"),
//    SearchUser(name: "gabby")
//    ]
    
    private let locationTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.textColor = .label
        title.font = .systemFont(ofSize: 15, weight: .medium)
        title.sizeToFit()
        return title
    }()
    
//    private var locationString: String?
    
    private let boomButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "pin.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 15)), for: .normal)
//        button.setTitle("Pin", for: .normal)
//        button.setTitleColor(.systemYellow, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.tintColor = .systemYellow
        button.backgroundColor = .black
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        
        return button
    }()
   
    private var horizonatlstackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.backgroundColor = .none
        stack.spacing = 5
        return stack
    }()
    
    private let mapsButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "maps"), for: .normal)
        button.tintColor = .label
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    
    private let uberButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "uber"), for: .normal)
        button.tintColor = .label
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    
    private let collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 3
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.backgroundColor = .none
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.register(BoomingCollectionViewCell.self,
                                    forCellWithReuseIdentifier: BoomingCollectionViewCell.identifier)
            return collectionView
        }()
    
    
    
  
    
    var locationString: String = "Location" {
       didSet {
           locationTitle.text = pin?.locationString
          // call delegate here if needed as well
       }
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        

        backgroundColor = .clear
        addSubview(locationTitle)
        addSubview(horizonatlstackView)
        addSubview(collectionView)
        addSubview(boomButton)
//        horizonatlstackView.addArrangedSubview(boomButton)
        horizonatlstackView.addArrangedSubview(mapsButton)
        horizonatlstackView.addArrangedSubview(uberButton)
       
        collectionView.delegate = self
        collectionView.dataSource = self
        
     
        boomButton.addTarget(self, action: #selector(didTapBoomButton), for: .touchUpInside)
        mapsButton.addTarget(self, action: #selector(didTapMaps), for: .touchUpInside)
        uberButton.addTarget(self, action: #selector(didTapUber), for: .touchUpInside)
        
        observer = NotificationCenter.default.addObserver(forName: .didTapPin, object: nil, queue: .main, using: { [weak self] noti in


            guard let pinInfo = noti.userInfo?.first?.value as? Pin else {
                return
            }

//            print("People: \(self?.peopleJoining)")
            self?.coordinates = CLLocationCoordinate2D(latitude: pinInfo.cooordinates.longitude, longitude: pinInfo.cooordinates.longitude)

            self?.locationString = pinInfo.locationString
            self?.locationTitle.text = pinInfo.locationString
            self?.peopleJoining = pinInfo.people
            self?.collectionView.reloadData()
        })
}


    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
    
        locationTitle.frame = CGRect(x: 0,
                             y: 0,
                             width: width,
                             height: 15)
        
        collectionView.frame = CGRect(x: 0, y: locationTitle.bottom+10, width: width, height: 50)
        
        boomButton.frame = CGRect(x: 0,
                                  y: collectionView.bottom,
                                  width: 25,
                                  height: 25)
        horizonatlstackView.frame = CGRect(x: (width-55),
                                           y: collectionView.bottom,
                                           width: 60,
                                           height: 25)
       
      
        
    }
    
    
    @objc func didTapBoomButton() {
        guard let coordinates = coordinates,
              let locationString = locationTitle.text else {
            return
        }
        
        delegate?.boomingDidPin(self, coordinates: coordinates, locationTitle: locationString)
        print("Did Tap Booming")
        
//
    }
    @objc func didTapMaps() {
        print("Tapped Maps")
        guard let coordinates = coordinates,
              let locationString = locationTitle.text else {
            return
        }
        
        
        
        delegate?.boomingViewDidTapMaps(self, coordinates: coordinates, locationTitle: locationString)
    
//        delegate?.boomingViewDidTapMaps(self)
//
    }
    @objc func didTapUber() {
        print("Tapped uber")
        guard let coordinates = coordinates,
              let locationString = locationTitle.text else {
            return
        }
      
        delegate?.boomingViewDidTapUber(self, coordinates: coordinates, locationTitle: locationString)
     
    
//
    }
    
   
//    public func configure(pin: Pin) {
//
//
//        self.pin = pin
////        self.locationString = pin.locationString
//        self.coordinates = CLLocationCoordinate2D(latitude: pin.cooordinates.latitude, longitude: pin.cooordinates.longitude)
//
//
//        DispatchQueue.main.async {
//            self.locationTitle.text = self.locationString
////            self.locationTitle.text = pin.locationString
////            self.collectionView.reloadData()
////            self.peopleJoining = pin.people
////            self.locationString = pin.locationString
//        }
//
//        print("Booming people: \(pin.people) and \(pin.locationString)")
//    }



}


extension BoomingView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("People count: \(peopleJoining.count)")
        return peopleJoining.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = peopleJoining[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoomingCollectionViewCell.identifier, for: indexPath)  as? BoomingCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: model)
        return cell
    }
    
   
    
    
}

