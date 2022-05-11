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
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String: String]]()
    private var results = [SearchUser]()
    private var checkedItems = Set<SearchUser>()
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
                                                         action: #selector(didSelectNext))
    
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
                                     y: view.safeAreaInsets.top,
                                     width: view.width,
                                     height: 50)

            tableView.frame = CGRect(x: 0,
                                     y: searchBar.bottom,
                                     width: view.width,
                                     height: view.height-50-50)
            noResultsLabel.frame = CGRect(x: view.width/4,
                                          y: (view.height-200)/2,
                                          width: view.width/2,
                                          height: 200)
            
       
        }
       
    
    
    

    @objc private func didSelectNext() {

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
                    navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            
            
        
        }
        
        
    }

}

extension AddNewPeopleToLinkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let resultSet = Array(Set(results))
        return resultSet.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableHeaderView.reloadData()
        let resultSet = Array(Set(results))
        let item = resultSet[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier,for: indexPath) as! NewConversationCell
        cell.configure(with: item)
        if checkedItems.contains(item) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath, animated: true)
        let item = results[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
       
        if checkedItems.contains(item) {
                checkedItems.remove(item)
            cell?.accessoryType = .none
            if self.targetUserDataArray.count > 0 {
                self.targetUserDataArray.remove(at: indexPath.row)
               self.targetUserDataArray = Array(Set(self.targetUserDataArray))
                print("A value has been removed: \(self.targetUserDataArray)")
//                tableHeaderView.reloadData()
                tableView.reloadData()
            }
            } else {
                checkedItems.insert(item)
                cell?.accessoryType = .checkmark
                self.targetUserDataArray.append(results[indexPath.row])
                self.targetUserDataArray = Array(Set(self.targetUserDataArray))
                print("A value has been added: \(self.targetUserDataArray)")
//                tableHeaderView.reloadData()
                tableView.reloadData()
            }
 
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
                    self?.tableView.reloadData()
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



    
