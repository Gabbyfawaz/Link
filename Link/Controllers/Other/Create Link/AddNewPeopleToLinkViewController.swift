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

    public var completion: (([SearchUser]) -> (Void))?
//    public var completion: (([SearchResults]) -> (Void))?
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String: String]]()
//    private var results = [SearchResult]()
    private var results = [SearchUser]()
//    private var results2 = [SearchUser]()
//    private var targetUserDataArray = [SearchResult]()
//    static var staticTargetUsers = [SearchResult]()
    
    private var targetUserDataArray = [SearchUser]()
    static var staticTargetUsers = [SearchUser]()
    
//    private var coordinates: CLLocationCoordinate2D?
//    private var locationTitle: String?
//    private let arrayOfImage: [UIImage]
//    private let typeOfLink: String
//    private let iconImage: UIImage
//    private let caption: String
    private var selectedIndexPath: IndexPath? = nil


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
       
        table.register(CustomizedHeaderViewForInvites.self, forHeaderFooterViewReuseIdentifier: CustomizedHeaderViewForInvites.identifier)
        return table
    }()

    private let tableHeaderView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(CustomizedHeaderViewForInvites.self, forHeaderFooterViewReuseIdentifier: CustomizedHeaderViewForInvites.identifier)
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let vcs = self.navigationController?.viewControllers {
            let previousVC = vcs[vcs.count - 2]
            if previousVC is FinalPageCreateLinkViewController {
                navigationItem.rightBarButtonItem?.title = "Done"
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        addAllSubviews()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        
//        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next",
                                                            style: .done,
                                                            target: self,
                                                         action: #selector(dismissSelf))
    
    }
    
//    init(arrayOfImage: [UIImage], locationTitle: String?, coordinates: CLLocationCoordinate2D?, typeOfLink: String, iconImage: UIImage, caption:String) {
//
//        self.arrayOfImage = arrayOfImage
//        self.locationTitle = locationTitle
//        self.coordinates = coordinates
//        self.typeOfLink = typeOfLink
//        self.iconImage = iconImage
//        self.caption = caption
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    private func configureNavigation() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .label
        title = "Add Friends"
        
    }
    
    private func addAllSubviews() {
        view.addSubview(searchBar)
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
       
            
            searchBar.frame = CGRect(x: 0,
                                     y: 100,
                                     width: view.width,
                                     height: 50)
//            usersAddedToCollectionView.frame = CGRect(x: 0,
//                                                      y: searchBar.bottom+5,
//                                                      width: view.width,
//                                                      height: 100)
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

//        completion?(self.targetUserDataArray)
        print("The completion value: \(self.targetUserDataArray)")
       

        if targetUserDataArray.count == 0 {
            let alert = UIAlertController(title: "Select More People", message: "Select at least one person", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again!", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            
           
            if let vcs = self.navigationController?.viewControllers {
                let previousVC = vcs[vcs.count - 2]
                if previousVC is FinalPageCreateLinkViewController {
                    AddNewPeopleToLinkViewController.staticTargetUsers = self.targetUserDataArray
                    navigationController?.popViewController(animated: true)
                } else if previousVC is MapViewController {
                    AddNewPeopleToLinkViewController.staticTargetUsers = targetUserDataArray
                    let vc = FinalPageCreateLinkViewController()
        //            let vc = FinalPageCreateLinkViewController(arrayOfImage: arrayOfImage, locationTitle: locationTitle, coordinates: coordinates, results: targetUserDataArray, typeOfLink: typeOfLink, iconImage: iconImage, caption: self.caption)
                    navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            
            
        
        }
        
        
    }

}

extension AddNewPeopleToLinkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier,for: indexPath) as! NewConversationCell
        cell.configure(with: model)
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        // add check mark to user
        
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        
        if !cell.isSelected {
            tableView.deselectRow(at: indexPath, animated: true)
            cell.accessoryType = .none
            if self.targetUserDataArray.count > 0 {
                self.targetUserDataArray.remove(at: indexPath.row)
               self.targetUserDataArray = Array(Set(self.targetUserDataArray))
                print("A value has been removed: \(self.targetUserDataArray)")
                tableHeaderView.reloadData()
            }
        } else {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            cell.accessoryType = .checkmark
            self.targetUserDataArray.append(results[indexPath.row])
            self.targetUserDataArray = Array(Set(self.targetUserDataArray))
            print("A value has been added: \(self.targetUserDataArray)")
            tableHeaderView.reloadData()
        }
        
        
        
//        if selectedIndexPath == indexPath {
//            // it was already selected
//            selectedIndexPath = nil
//            cell.accessoryType = .none
//            tableView.deselectRow(at: indexPath, animated: false)
//            
//            if self.targetUserDataArray.count > 0 {
//                self.targetUserDataArray.remove(at: indexPath.row)
//               self.targetUserDataArray = Array(Set(self.targetUserDataArray))
//                print("A value has been removed: \(self.targetUserDataArray)")
//                tableView.reloadData()
//            }
//           
//            
//        } else {
//            // wasn't yet selected, so let's remember it
////            tableView.deselectRow(at: indexPath, animated: false)
//            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
////            selectedIndexPath = indexPath
//            cell.accessoryType = .checkmark
//            self.targetUserDataArray.append(results[indexPath.row])
//            self.targetUserDataArray = Array(Set(self.targetUserDataArray))
//            print("A value has been added: \(self.targetUserDataArray)")
//            tableView.reloadData()
//
//            
//            
//        }
//        
//       
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        

        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomizedHeaderViewForInvites.identifier) as? CustomizedHeaderViewForInvites else {
            fatalError("There was no returned header view here")
        }
        print("We are sending data to target: \(self.targetUserDataArray)")
        view.configure(with: self.targetUserDataArray )
        
        return view
   
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.targetUserDataArray.count > 0 {
            return 100
        } else {
            return 0
        }
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
        
        guard hasFetched else {
            return
        }
        
        self.spinner.dismiss()

        let results: [SearchUser] = users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }

            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let name = $0["name"] else {
                return nil
            }

            return SearchUser(name: name)
        })

        self.results = results
        updateUI()
    }
    
//    func filterUsers(with term: String) {
//        // update the UI: eitehr show results or show no results label
//        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
//            return
//        }
//
//        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
//
//        self.spinner.dismiss()
//
//        let results: [SearchResult] = users.filter({
//            guard let email = $0["email"], email != safeEmail else {
//                return false
//            }
//
//            guard let name = $0["name"]?.lowercased() else {
//                return false
//            }
//
//            return name.hasPrefix(term.lowercased())
//        }).compactMap({
//
//            guard let email = $0["email"],
//                let name = $0["name"] else {
//                return nil
//            }
//
//            return SearchResult(name: name, email: email)
//        })
//
//        self.results = results
//
//        updateUI()
//    }

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



    
