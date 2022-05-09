//
//  CategoryViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/08/10.
//

import UIKit
import CoreLocation

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
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
    
//    private let searchBar: UISearchBar = {
//        let searchBar = UISearchBar()
//        return searchBar
//    }()

    private var sections: [CategorySection] = []
    
    private var filteredSections = [CategorySection]()
    public var titleOfLink: String?
    static var staticTitleOfLink: String?
//    private var arrayOfImage: [UIImage]
//    private var iconImage: UIImage
//    private var caption: String
//    private var uniqueNameOfLink: String?

    // MARK: - Lifecycle
    
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
        navigationController?.navigationBar.tintColor = .label
        view.backgroundColor = .systemBackground
        title = "Categories"
        view.addSubview(tableView)
//        view.addSubview(searchBar)
//        searchBar.delegate = self
        configureModels()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = false
        
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(didTapDone))
       
       
        
        
//        createTableFooter()
    }
    
    //MARK: - Init
    
//    init(arrayOfImage: [UIImage], iconImage: UIImage, caption: String) {
//        self.arrayOfImage = arrayOfImage
//        self.iconImage = iconImage
//        self.caption = caption
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    //MARK: - Actions
    
    private func alertPopUp(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func configureCategoryTitle() {
        if let titleOfLink = self.titleOfLink {
            if titleOfLink == "Custom Link" {
                alertPopUp(message: "No Category Choosen")
            }
//            let vc = LocationViewController(arrayOfImage: arrayOfImage, typeOfLink: titleOfLink, iconImage: iconImage, caption: self.caption)
//
//            navigationController?.pushViewController(vc, animated: true)
            
            print("the type of link selected is: \(titleOfLink)")
            CategoryViewController.staticTitleOfLink = titleOfLink
//            let vc = SearchResultTableViewController(arrayOfImage: self.arrayOfImage, iconImage: self.iconImage, caption: self.caption, category: titleOfLink)
            let vc = SearchResultTableViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            alertPopUp(message: "No Category Choosen")
        }
    }
    
     private func didTapNext() {
        if  let index = tableView.indexPathForSelectedRow, let cell = tableView.cellForRow(at: index ) {
            if cell.isSelected {
                if let titleOfLink = self.titleOfLink {
                    CategoryViewController.staticTitleOfLink = titleOfLink
                    if titleOfLink == "Custom Link" {
                        alertPopUp(message: "No Category Choosen")
                    }

                    print("the type of link selected is: \(titleOfLink)")
                    CategoryViewController.staticTitleOfLink = titleOfLink 
                    navigationController?.popViewController(animated: true)
                }
            } else {
                alertPopUp(message: "No Category Choosen")
            }
            
        } else {
            alertPopUp(message: "Select a category")
        }
        

        
    }
    
 
    
    @objc func didTapDone() {
        if let vcs = self.navigationController?.viewControllers {
            let previousVC = vcs[vcs.count - 2]
            if previousVC is FinalPageCreateLinkViewController {
                didTapNext()
//                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(didTapNext) )
            } else if previousVC is PostEditViewController {
                configureCategoryTitle()
            }
            
       

        }
               
    }

    
    //MARK: - Layout Subviews

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        searchBar.frame = CGRect(x: 0,
//                                 y: 150,
//                                 width: view.width,
//                                 height: 50)
        tableView.frame = view.frame
        
//        noResultsLabel.frame = CGRect(x: view.width/4,
//                                      y: (view.height-200)/2,
//                                      width: view.width/2,
//                                      height: 200)
    }
    

    
   //MARK: - TableView (Delegate/DataSource)

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return sections[section].options.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        if let selectedRows = tableView.indexPathsForSelectedRows,
                    selectedRows.contains(indexPath)
                {
                    cell.accessoryType = .checkmark

                } else {
                    cell.accessoryType = .none
                }
        return cell
    }
    
 
      func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
          let cell = self.tableView.cellForRow(at: indexPath)
          cell?.accessoryType = .none
      }


    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        let cell = self.tableView.cellForRow(at: indexPath)
//        tableView.deselectRow(at: indexPath, animated: true)
        cell?.accessoryType = .checkmark
       


        let titleOfLink = sections[indexPath.section].options[indexPath.row].title
        self.titleOfLink = titleOfLink
        
        
        if titleOfLink == "Custom Link" {
            let alert = UIAlertController(title: "Custom your link", message: "Make it interesting!", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.text = ""
            }
            
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                guard let typeOfLink = textField?.text else {return}
                
                guard !typeOfLink.trimmingCharacters(in: .whitespaces).isEmpty else {
                    self.alertPopUp(message: "No Text Entered")
                    return
                }
                
                
//                let vc = MapViewController()
//                self.navigationController?.pushViewController(vc, animated: true)
                
//                let vc = LocationViewController(arrayOfImage: self.arrayOfImage, typeOfLink: typeOfLink, iconImage: self.iconImage, caption: self.caption, locationTitle: publicLocationTitle, coordinates: publicCoordinates,guestInvited: publicGuestsInvited)
                
                print("this is the type of link: \(typeOfLink)")
                CategoryViewController.staticTitleOfLink = typeOfLink
//                let vc = SearchResultTableViewController(arrayOfImage: self.arrayOfImage, iconImage: self.iconImage, caption: self.caption, category: typeOfLink)
                
            if let vcs = self.navigationController?.viewControllers {
                    let previousVC = vcs[vcs.count - 2]
                if previousVC is FinalPageCreateLinkViewController {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let vc = SearchResultTableViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
                
              
                
              
                
            }))

            self.present(alert, animated: true, completion: nil)
        }
        
    
        print(titleOfLink)
        
       

        
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    
    //MARK: - Configure Model
    
    private func configureModels() {
        sections.append(
            CategorySection(title: "Custom",
                            options: [
                                CategoryName(title: "Custom Link"),
                                
                            ]))
        
        sections.append(
            CategorySection(title: "Social Events",
                            options: [
                                CategoryName(title: "Birthday Party"),
                                CategoryName(title: "House Party"),
                                CategoryName(title: "Private Party"),
                                CategoryName(title: "Public Party"),
                                CategoryName(title: "Beach Party"),
                                CategoryName(title: "Street Party")
                                
                            ]))
            sections.append(
                CategorySection(title: "Intimate Events",
                                options: [
                                    CategoryName(title: "Sneaky Link"),
                                    CategoryName(title: "Cheaky Link"),
                                    CategoryName(title: "Date"),
                                    CategoryName(title: "Dinner"),
                                    CategoryName(title: "Brunch"),
                                    CategoryName(title: "Lunch")
                                    
                                ]))
        
        sections.append(
            CategorySection(title: "Festivals",
                            options: [
                                CategoryName(title: "Music Festival"),
                                CategoryName(title: "Food Festival")
                            ]))
                
                sections.append(
                    CategorySection(title: "Amusement",
                                    options: [
                                        CategoryName(title: "Museum"),
                                        CategoryName(title: "Expedition"),
                                        CategoryName(title: "Theater"),
                                        CategoryName(title: "Cinema"),
                                        CategoryName(title: "Theme Park"),
                                        
                                    ]))
        
        sections.append(
            CategorySection(title: "Coperate",
                            options: [
                                CategoryName(title: "Conferences"),
                                CategoryName(title: "Seminers"),
                                CategoryName(title: "Trade Shows"),
                                CategoryName(title: "Workshops"),
                                
                            ]))
    
        
        sections.append(
            CategorySection(title: "Virtual Events",
                            options: [
                                CategoryName(title: "Webinars"),
                                CategoryName(title: "Classes"),
                                CategoryName(title: "Summits"),
                                CategoryName(title: "Masterclass")
                                
                            ]))

        
        sections.append(
            CategorySection(title: "Sporting Events",
                            options: [
                                CategoryName(title: "Football"),
                                CategoryName(title: "Basketball"),
                                CategoryName(title: "Hockey"),
                                CategoryName(title: "Golf"),
                                CategoryName(title: "Tennis"),
                                CategoryName(title: "Training "),
                            
                            ]))
        
        
        sections.append(
            CategorySection(title: "Real Estate",
                            options: [
                                CategoryName(title: "House Viewing"),
                            ]))
        
        sections.append(
            CategorySection(title: "Fundraisers",
                            options: [
                                CategoryName(title: "Auctions"),
                                CategoryName(title: "Galas")
                            ]))
        
                
                
            
    }


}





//extension CategoryViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
//            return
//        }
//        searchBar.resignFirstResponder()
//
//        guard let searchText = searchBar.text else { return }
//        filterCategory(searchText: searchText)
//
//    }
//
//    func filterCategory(searchText: String) {
//        filteredSections = sections.filter { item in
//            if searchBar.text != "" {
//                let searchItemText = item.title.lowercased().contains(searchText.lowercased())
//                return searchItemText
//            } else {
//                return false
//            }
//
//        }
//        print("FilteredSections: \(filteredSections)")
//        tableView.reloadData()
//        updateUI()
//
//    }
//
//    func updateUI() {
//        if filteredSections.isEmpty {
//            noResultsLabel.isHidden = false
//            tableView.isHidden = true
//        }
//        else {
//            noResultsLabel.isHidden = true
//            tableView.isHidden = false
//            tableView.reloadData()
//        }
//    }
//
//}
//
