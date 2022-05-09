//
//  SearchResultsLinkViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/08/20.
//

import UIKit

protocol SearchResultsLinkViewControllerDelegate: AnyObject {
    func searchResultsViewController(_ vc: SearchResultsLinkViewController, didSelectResultWith links: LinkModel)
}

class SearchResultsLinkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    public weak var delegate: SearchResultsLinkViewControllerDelegate?

    private var link = [LinkModel]()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
       
    }
    
    public func update(with results: [LinkModel]) {
        self.link = results
        tableView.reloadData()
        tableView.isHidden = link.isEmpty
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return link.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = link[indexPath.row].linkTypeName
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchResultsViewController(self, didSelectResultWith: link[indexPath.row])
    }
}

