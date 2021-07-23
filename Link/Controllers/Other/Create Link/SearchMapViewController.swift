//
//  SearchMapViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//
import UIKit
import CoreLocation

protocol SearchMapViewControllerDelegate: AnyObject {
    func searchMapViewController(_ vc: SearchMapViewController,
                                 didSelectLocationWith coordinates: CLLocationCoordinate2D?, title: String?)
}

class SearchMapViewController: UIViewController, UITextFieldDelegate{

    
    //MARK: - Properties

    weak var delegate: SearchMapViewControllerDelegate?
    private let field: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter Link Location"
        field.backgroundColor = .tertiarySystemBackground
        field.layer.cornerRadius = 9
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        field.leftViewMode = .always
        return field
        
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .secondarySystemBackground
        return table
    }()
    
    var location = [LocationMaps]()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(field)
        view.addSubview(tableView)
        field.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .secondarySystemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        field.frame = CGRect(x: 10, y: 20, width: view.frame.size.width-20, height: 40)
        let tableY: CGFloat = field.frame.origin.y+field.frame.size.height+5
        tableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height-tableY)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        if let text = field.text, !text.isEmpty {
            LocationManager.shared.findLocation(with: text, completion: { [weak self] location in
                // update table view
                DispatchQueue.main.async {
                    self?.location = location
                    self?.tableView.reloadData()
                }
            })
        }
        return true
    }
    

}

extension SearchMapViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return location.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = location[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let coordinate = location[indexPath.row].coordinates
        let title = location[indexPath.row].title
        delegate?.searchMapViewController(self, didSelectLocationWith: coordinate, title: title)
        
        // notify map controller to show at selected place
    }
    
    
}

