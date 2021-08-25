//
//  AddNewPeopleToLinkViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import JGProgressHUD
import CoreLocation

final class AddNewPeopleToLinkViewController: UIViewController {

    public var completion: (([SearchResult]) -> (Void))?

    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    private var targetUserDataArray = [SearchResult]()
    private var coordinates: CLLocationCoordinate2D?
    private var locationTitle: String?
    private let arrayOfImage: [UIImage]
    private let typeOfLink: String
    private let iconImage: UIImage
    private let caption: String


    private var hasFetched = false

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationCell.self,
                       forCellReuseIdentifier: NewConversationCell.identifier)
        return table
    }()

    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Add Friends"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
    
        view.addSubview(searchBar)
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
//        view.backgroundColor = .systemBackground

        tableView.delegate = self
        tableView.dataSource = self

        searchBar.delegate = self
        
//        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next",
                                                            style: .done,
                                                            target: self,
                                                         action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    init(arrayOfImage: [UIImage], locationTitle: String?, coordinates: CLLocationCoordinate2D?, typeOfLink: String, iconImage: UIImage, caption:String) {
        
        self.arrayOfImage = arrayOfImage
        self.locationTitle = locationTitle
        self.coordinates = coordinates
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
        searchBar.frame = CGRect(x: 0,
                                 y: 100,
                                 width: view.width,
                                 height: 50)
        tableView.frame = CGRect(x: 0,
                                 y: searchBar.bottom,
                                 width: view.width,
                                 height: view.height-150)
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-200)/2,
                                      width: view.width/2,
                                      height: 200)
    }

    @objc private func dismissSelf() {
   

        completion?(self.targetUserDataArray)
        

        if targetUserDataArray.count == 0 {
            let alert = UIAlertController(title: "Select More People", message: "Select Link Icon Please", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again!", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            let vc = CreateLinkViewController(arrayOfImage: arrayOfImage, locationTitle: locationTitle, coordinates: coordinates, results: targetUserDataArray, typeOfLink: typeOfLink, iconImage: iconImage, caption: self.caption)
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }

}

extension AddNewPeopleToLinkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier,
                                                 for: indexPath) as! NewConversationCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // add check mark to user
        
//        let targetUserData = results[indexPath.row]
        
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            targetUserDataArray.append(results[indexPath.row])
            
            
//            targetUserDataArray = [targetUserData]

            
        }
         
 
        
        //-> append to list of users array

        
//        dismiss(animated: true, completion: { [weak self] in
//            self?.completion?(targetUserDataArray)
//        })
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension AddNewPeopleToLinkViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }

        searchBar.resignFirstResponder()

        results.removeAll()
        spinner.show(in: view)

        searchUsers(query: text)
    }

    func searchUsers(query: String) {
        // check if array has firebase results
        if hasFetched {
            // if it does: filter
            filterUsers(with: query)
        }
        else {
            // if not, fetch then filter
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get usres: \(error)")
                }
            })
        }
    }

    func filterUsers(with term: String) {
        // update the UI: eitehr show results or show no results label
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }

        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)

        self.spinner.dismiss()

        let results: [SearchResult] = users.filter({
            guard let email = $0["email"], email != safeEmail else {
                return false
            }

            guard let name = $0["name"]?.lowercased() else {
                return false
            }

            return name.hasPrefix(term.lowercased())
        }).compactMap({

            guard let email = $0["email"],
                let name = $0["name"] else {
                return nil
            }

            return SearchResult(name: name, email: email)
        })

        self.results = results

        updateUI()
    }

    func updateUI() {
        if results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

}

