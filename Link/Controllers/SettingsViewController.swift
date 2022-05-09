//
//  SettingsViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import SafariServices
import UIKit
import MessageKit

enum RelationshipStatus {
    case isPrivate
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    private var observer: NSObjectProtocol?
    private var isPrivate = false
    private let privacySwitch = UISwitch(frame: .zero)
    private var sections: [SettingsSection] = []
    private var action = RelationshipStatus.isPrivate

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
//        tableView.addSubview(privacySwitch)
        fetchStateOfSwitch()
        view.addSubview(tableView)
        configureModels()
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        createTableFooter()
        // place this in an observer
        
//        observer = NotificationCenter.default.addObserver(
//            forName: .didLoginNotification,
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            self?.fetchStateOfSwitch()
//            self?.tableView.reloadData()
//        }
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }

//     @objc func didSwitchChangeState() {
//        self.isPrivate = !self.isPrivate
//
//        if self.isPrivate == true {
//            self.privacySwitch.setOn(isPrivate, animated: true)
//        } else {
//            self.privacySwitch.setOn(isPrivate, animated: true)
//        }
//
//         // put the users state of privacy in database
//    }
    
    func fetchStateOfSwitch() {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            fatalError("Problem retriving username from user defaults")
        }
        
        DatabaseManager.shared.isUserPrivate(username: username) { isPrivate in
            if isPrivate {
                self.isPrivate = true
                DispatchQueue.main.async {
                    self.privacySwitch.isOn = true
                }
                print("the state of private: \(self.isPrivate)")
                
            } else {
                self.isPrivate = false
                DispatchQueue.main.async {
                    self.privacySwitch.isOn = false
                }
                print("Error cheching if the user is private")
            }
           
        }
    }
    
   @objc private func alertPopUp() {
        let actionSheet = UIAlertController(title: "Are you sure", message: "This action will change the state of your privacy", preferredStyle: .actionSheet)
       
       actionSheet.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.configureSwitchSwitch()
        }))

       actionSheet.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
//           self.isPrivate = !self.isPrivate
          ///check current state
           ///
           if self.privacySwitch.isOn == true {
               self.privacySwitch.isOn = false
           } else {
               self.privacySwitch.isOn = true
           }
//           if self.isPrivate {
//               self.privacySwitch.isOn = !self.isPrivate
//           } else {
//               self.privacySwitch.isOn = self.isPrivate
//           }
          
       }))
       self.present(actionSheet, animated: true, completion: nil)
       
    }
    
     private func configureSwitchSwitch() {
  
        isPrivate = !isPrivate
        switchChanged()

        if isPrivate == true {
            privacySwitch.isOn = true
            print("isPrivate is true and the button is on")
        } else {
            privacySwitch.isOn = false
            print("isPrivate is false and the button is off")
            DatabaseManager.shared.deleteRequestingUsersWhenPublic { success in
                if success {
                    print("congradulations you have sucessfully delete requesting and put them to follows")
                }
            }
       
        }

    }
    
    func switchChanged(){
        
        switch action {
        case .isPrivate:
            if self.isPrivate {
                DatabaseManager.shared.UpdatePrivateState(state: .isPrivate) { success in
                        if !success {
                            print("failed to follow")
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } else {
                            print("successfully saved data to database")
                        }
                }
            } else {
                DatabaseManager.shared.UpdatePrivateState(state: .notPrivate) { success in
                        if !success {
                            print("failed to follow")
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } else {
                            print("successfully removed data to database")
                        }
                }
                
            }
            
        }
//        isPrivate = !isPrivate
    print("The state of the button currently is: \(isPrivate)")
//        DispatchQueue.main.async {
//            self.configureSwitchSwitch()
//        }
   
   // save the state of isPrivate to the database
        
    

        

    }
    
    private func configureModels() {
        sections.append(
            SettingsSection(title: "Privacy",
                            options: [
                                SettingOption(title: "Private",image: UIImage(systemName: "lock"), color: .black, handler: {
                                   /// do not handle yet , the function didSwitchChangeState will handle this case
                                })]))
        sections.append(
            SettingsSection(title: "App", options: [
                SettingOption(
                    title: "Rate App",
                    image: UIImage(systemName: "star"),
                    color: .systemOrange
                ) {
                    guard let url = URL(string: "https://apps.apple.com/us/app/instagram/id389801252") else {
                        return
                    }
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                },
                SettingOption(
                    title: "Share App",
                    image: UIImage(systemName: "square.and.arrow.up"),
                    color: .systemBlue
                ) { [weak self] in
                    guard let url = URL(string: "https://apps.apple.com/us/app/instagram/id389801252") else {
                        return
                    }
                    DispatchQueue.main.async {
                        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
                        self?.present(vc, animated: true)
                    }
                }
            ])
        )

        sections.append(
            SettingsSection(title: "Information", options: [
                SettingOption(
                    title: "Terms of Service",
                    image: UIImage(systemName: "doc"),
                    color: .systemPink
                ) { [weak self] in
                    DispatchQueue.main.async {
                        guard let url = URL(string: "https://help.instagram.com/581066165581870?helpref=page_content") else {
                            return
                        }
                        let vc = SFSafariViewController(url: url)
                        self?.present(vc, animated: true, completion: nil)
                    }
                },
                SettingOption(
                    title: "Privacy Policy",
                    image: UIImage(systemName: "hand.raised"),
                    color: .systemGreen
                ) { [weak self] in
                    guard let url = URL(string: "https://help.instagram.com/519522125107875") else {
                        return
                    }
                    let vc = SFSafariViewController(url: url)
                    self?.present(vc, animated: true, completion: nil)

                },
                SettingOption(
                    title: "Get Help",
                    image: UIImage(systemName: "message"),
                    color: .systemPurple
                ) { [weak self] in
                    guard let url = URL(string: "https://help.instagram.com/") else {
                        return
                    }
                    let vc = SFSafariViewController(url: url)
                    self?.present(vc, animated: true, completion: nil)

                }
            ])
        )
    }

    // Table

    private func createTableFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        footer.clipsToBounds = true

        let button = UIButton(frame: footer.bounds)
        footer.addSubview(button)
        button.setTitle("Sign Out",
                        for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)

        tableView.tableFooterView = footer
    }

    @objc func didTapSignOut() {
        let actionSheet = UIAlertController(
            title: "Sign Out",
            message: "Are you sure?",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] _ in
            AuthManager.shared.signOut { success in
                if success {
                    DispatchQueue.main.async {
                        let vc = SignInViewController()
                        let navVC = UINavigationController(rootViewController: vc)
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true)
                    }
                }
            }
        }))
        present(actionSheet, animated: true)
    }

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
        cell.imageView?.image = model.image
        cell.imageView?.tintColor = model.color
        cell.accessoryType = .disclosureIndicator
        
        if cell.textLabel?.text == "Private" {
//            privacySwitch.tag = indexPath.row // for detect which row switch Changed
            //            self.privacySwitch.addTarget(self, action: #selector(didSwitchChangeState), for: .touchUpInside)
            //            cell.accessoryView = self.privacySwitch
//            let switchView = UISwitch(frame: .zero)
//            privacySwitch.setOn(false, animated: true)
//            switchView.tag = indexPath.row // for detect which row switch Changed
            privacySwitch.addTarget(self, action: #selector(alertPopUp), for: .valueChanged)
            cell.accessoryView = privacySwitch
            cell.accessoryType = .none
        }
       
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

