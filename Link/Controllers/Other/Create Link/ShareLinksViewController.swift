//
//  ShareLinksViewController .swift
//  Link
//
//  Created by Gabriella Fawaz on 01/03/2022.
//

//import UIKit
//import JGProgressHUD
//
//
//struct ShareSection {
//    let sectionTitle: String
//    let options: [SectionType]
//}
//
//struct SectionType {
//    let links: [String]?
//    let share: [SearchUser]?
//}
//
//class ShareLinksViewController: UIViewController {
//    
//    //MARK: PROPERTIES
//    
//    private let sectionTitle = ["Links", "Users"]
//    private var section = [ShareSection]()
//    private let spinner = JGProgressHUD(style: .dark)
//    private var results = [SearchUser]()
//    private var searchResults = [SearchUser]()
//    private var hasFetched = false
//    private var users = [[String: String]]()
//    private let tableView: UITableView = {
//        let tv = UITableView()
//        tv.register(ShareLinkWithUsersCell.self,
//                       forCellReuseIdentifier: ShareLinkWithUsersCell.identifier)
//        return tv
//    }()
//    private let searchBar: UISearchBar = {
//        let searchBar = UISearchBar()
//        searchBar.placeholder = "Search for Users..."
////        searchBar.showsCancelButton = true
//        return searchBar
//    }()
//    
//    //MARK: LIFECYCLE
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureNavigation()
//        view.addSubview(tableView)
//        view.addSubview(searchBar)
//        tableView.delegate = self
//        tableView.dataSource = self
//        searchBar.delegate = self
////        searchBar.becomeFirstResponder()
//        fetchUsers()
//    }
//    
//    
//
//    //MARK: Layout of Subviews 
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        searchBar.frame = CGRect(x: 0,
//                                 y: 0,
//                                 width: view.width,
//                                 height: 50)
//
//        tableView.frame = CGRect(x: 0,
//                                 y: searchBar.bottom,
//                                 width: view.width,
//                                 height: view.height-50)
//    }
//    
//    
//    //MARK: ACTIONS
//    
//     private func configureNavigation() {
//        view.backgroundColor = .systemBackground
//        navigationController?.navigationBar.tintColor = .label
//         navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
//        title = "Share Link"
//        
//    }
//    
//
//    
//    private func fetchUsers() {
//        let group = DispatchGroup()
//        group.enter()
//        var results = [SearchUser]()
//        DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
//            switch result {
//            case .success(let usersCollection):
//                defer {
//                    group.leave()
//                }
//                self?.users = usersCollection
//                usersCollection.forEach { collection in
//                    guard let name = collection["name"] else {
//                        return
//                    }
//                    let result = SearchUser(name: name)
//                    results.append(result)
//                }
//              
//            case .failure(let error):
//                print("Failed to get usres: \(error)")
//            }
//        })
//        
//        group.notify(queue: .main){
//            let finalResults = Array(Set(results))
//            self.results = finalResults
//            self.tableView.reloadData()
//        }
//
//    }
//    
//    
//    //MARK: ACTIONS
//    
//    @objc func didTapDone() {
//       tabBarController?.tabBar.isHidden = false
//       tabBarController?.selectedIndex = 0
//       navigationController?.navigationBar.tintColor = .black
//       navigationController?.popToRootViewController(animated: false)
//        print("done done done ")
//    }
//    
//}
//    
//
//extension ShareLinksViewController: UISearchBarDelegate {
//    
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//    }
//    
//    
//
//        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//            guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
//                return
//            }
//
//            searchBar.resignFirstResponder()
//
//            results.removeAll()
//            spinner.show(in: view)
//
//            searchUsers(query: text)
//        }
//        
//    func searchUsers(query: String) {
//        // check if array has firebase results
//        if hasFetched {
//            // if it does: filter
//            filterUsers(with: query)
//        }
//        else {
//            // if not, fetch then filter
//            hasFetched = true
//            filterUsers(with: query)
////            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
////                switch result {
////                case .success(let usersCollection):
////                    self?.hasFetched = true
////                    self?.users = usersCollection
////                    self?.filterUsers(with: query)
////                case .failure(let error):
////                    print("Failed to get usres: \(error)")
////                }
////            })
//        }
//    }
//    
//    func filterUsers(with term: String) {
//        
//        guard hasFetched else {
//            return
//        }
//        
//        self.spinner.dismiss()
//
////        let  results: [SearchUser] = results.filter ({
////             let name = $0.name
////            return name.hasPrefix(term.lowercased())
////        }).compactMap ({
////            let name = $0.name
////            return SearchUser(name: name)
////        })
//        
//        let results: [SearchUser] = users.filter({
//            guard let name = $0["name"]?.lowercased() else {
//                return false
//            }
//
//            return name.hasPrefix(term.lowercased())
//        }).compactMap({
//            guard let name = $0["name"] else {
//                return nil
//            }
//
//            return SearchUser(name: name)
//        })
//
//        self.results = results
//        updateUI()
//    }
//    
//    func updateUI() {
//        if results.isEmpty {
////            noResultsLabel.isHidden = false
//            tableView.isHidden = true
//        }
//        else {
////            noResultsLabel.isHidden = true
//            tableView.isHidden = false
//            tableView.reloadData()
//        }
//    }
//
//    }
//
//extension ShareLinksViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        if searchBar.isFirstResponder {
////            return searchResults.count
////        }else {
////            return results.count
////        }
//        return results.count
//    }
//    
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
////        var finalResults = [SearchUser]()
////        if searchBar.isFirstResponder {
////            finalResults = searchResults
////        }else {
////            finalResults = results
////        }
//        
//        let model = results[indexPath.row]
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShareLinkWithUsersCell.identifier, for: indexPath) as? ShareLinkWithUsersCell else {
//            fatalError()
//        }
//        cell.configure(with: model)
//        cell.delegate = self
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//    
//}
//
//extension ShareLinksViewController: ShareLinkWithUsersCellDelegate {
//    func ShareLinkWithUsersCellDidiTapShareButton(_ cell: ShareLinkWithUsersCell) {
//        print("I pressed this button")
//    }
//    
//    
//}
