//
//  QuickLinkMoreInfoFloatingPanel.swift
//  Link
//
//  Created by Gabriella Fawaz on 08/03/2022.
//

import UIKit
import CoreLocation
import MapKit
import UberRides


//protocol ContentViewControllerDelegate: AnyObject {
//    func contentViewControllerDidTapLocation(_ vc:ContentViewController)
//
class ContentViewController: UIViewController, CLLocationManagerDelegate {
   
    
//    weak var delegate: ContentViewControllerDelegate?
    private let locationManager = CLLocationManager()
    private var latitude: CLLocationDegrees?
    private var longitude: CLLocationDegrees?
    private let quickLink: QuickLink
    private let clockImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        iv.tintColor = .systemYellow
        return iv
    }()
    
    private let timeLabel: UILabel = {
        var timeLabel = UILabel()
        timeLabel.textAlignment = .left
        timeLabel.textColor = .label
        return timeLabel
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .label
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let noUsersLabel: UITextView = {
        let label = UITextView()
//        label.textAlignment = .center
        label.text = "No one has joined yet"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .systemYellow
        label.isHidden = true
        label.backgroundColor = .none
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let locationImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        iv.tintColor = .systemYellow
        iv.isUserInteractionEnabled = true
        return iv
    }()
    

    
    private let horizonatlstackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 5
        stack.backgroundColor = .none
        return stack
    }()
    
    private let horizonatlstackView2: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.backgroundColor = .none
        stack.spacing = 5
        return stack
    }()
    
    private let tableview: UITableView = {
        let tableview = UITableView()
        tableview.register(QuickLinkTableViewCell.self, forCellReuseIdentifier: QuickLinkTableViewCell.identifier)
        tableview.backgroundColor = .clear
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.8)
        view.addSubview(horizonatlstackView)
        horizonatlstackView.addArrangedSubview(clockImageView)
        horizonatlstackView.addArrangedSubview(timeLabel)
        view.addSubview(horizonatlstackView2)
        horizonatlstackView2.addArrangedSubview(locationImageView)
        horizonatlstackView2.addArrangedSubview(locationLabel)
        view.addSubview(noUsersLabel)
        view.addSubview(tableview)
        tableview.delegate = self
        tableview.dataSource = self
        configureUI()
        print("people joined \(quickLink.joined)")
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLocation))
//        locationLabel.addGestureRecognizer(tap)
//        locationImageView.addGestureRecognizer(tap)
        
    }
    
    init(quickLink: QuickLink) {
        self.quickLink = quickLink
          super.init(nibName: nil, bundle: nil)
      }
  
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        horizonatlstackView.frame = CGRect(x: 15, y: 25, width: view.width-30, height: 30)
        horizonatlstackView2.frame = CGRect(x: 15, y: horizonatlstackView.bottom+15, width: view.width-30, height: 30)
        tableview.frame = CGRect(x: 5, y: horizonatlstackView2.bottom, width: view.width-10, height: view.height-105)
        noUsersLabel.frame = CGRect(x: 5, y: horizonatlstackView2.bottom+10, width: view.width-10, height: view.height-105)
    }
    
    
    // MARK: ACTIONS
    
    public func configureUI() {

        if let timeInterval = quickLink.timestamp {
            let stringDate = DateFormatter.formatter.string(from: Date(timeIntervalSince1970: timeInterval))
            timeLabel.text = stringDate
        } else {
            timeLabel.text = "Date not set"
        }

        if let locationText = quickLink.locationTitle {
             locationLabel.text  = locationText
        } else {
            locationLabel.text = "Location not set"
        }
        
        if quickLink.joined.count == 0 {
            noUsersLabel.isHidden = false
            tableview.isHidden = true
        } else {
            noUsersLabel.isHidden = true
            tableview.isHidden = false
            tableview.reloadData()
        }
    }
    
    
    
//    @objc func didTapLocation() {
//        delegate?.contentViewControllerDidTapLocation(self)
//    }
//
    
    
  
}


extension ContentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quickLink.joined.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = quickLink.joined[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuickLinkTableViewCell.identifier, for: indexPath) as? QuickLinkTableViewCell else {
            fatalError("Could not dequeue cell " )
        }
        cell.backgroundColor = .clear
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "People coming"
    }
    
    
}


//    let join = [
//    SearchUser(name: "Josh"),
////    SearchUser(name: "jazmine"),
//    SearchUser(name: "tory"),
//    SearchUser(name: "olivia"),
//    SearchUser(name: "jamie"),
//    SearchUser(name: "gabby")
//    ]
