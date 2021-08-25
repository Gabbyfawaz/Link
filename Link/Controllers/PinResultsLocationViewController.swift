//
//  PinResultsLocationViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/08/17.
//

import UIKit
import CoreLocation

protocol PinResultsLocationViewControllerDelegate: AnyObject {
    func didTapPlace(with coordinates: CLLocationCoordinate2D)
}

class PinResultsLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: PinResultsLocationViewControllerDelegate?
    
    private var places: [Place] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "resultCell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    public func update(with places: [Place]) {
        self.tableView.isHidden = false
        self.places = places
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        cell.textLabel?.text = places[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.isHidden = true
        let place = places[indexPath.row]
        GooglePlacesManager.shared.resolveLocation(for: place) { result in
            
            switch result {
            case .success(let coordinate):
                DispatchQueue.main.async {
                    self.delegate?.didTapPlace(with: coordinate)
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

}
