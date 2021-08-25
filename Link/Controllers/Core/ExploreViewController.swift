//
//  ExploreViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

/// Explore / Discover controller that also supports search
final class ExploreViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {

    /// Search controller
    private var searchVC = UISearchController(searchResultsController: SearchResultsViewController())
    
    /// Primary exploreo UI component
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { index, _ -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1)
                )
            )

            let fullItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
//
//            let tripletItem = NSCollectionLayoutItem(
//                layoutSize: NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1/3),
//                    heightDimension: .fractionalHeight(1)
//                )
//            )
//
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1)
                ),
                subitem: fullItem,
                count: 1
            )

            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1/2)),
                subitems: [
                    item,
                    verticalGroup
                ]
            )
//
//            let threeItemGroup = NSCollectionLayoutGroup.horizontal(
//                layoutSize: NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1),
//                    heightDimension: .absolute(160)
//                ),
//                subitem: tripletItem,
//                count: 3
//            )

            let finalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1/2)
                ),
                subitems: [
//                    horizontalGroup,
//                    threeItemGroup
                    horizontalGroup
                ]
            )
            return NSCollectionLayoutSection(group: finalGroup)
        }

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ExploreCollectionViewCell.self,
                                forCellWithReuseIdentifier: ExploreCollectionViewCell.identifier)
        return collectionView
    }()

    private var links = [(link: LinkModel, user: User)]()
    
//    private var category = ["Users", "Links"]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explore"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        
        (searchVC.searchResultsController as? SearchResultsViewController)?.delegate = self
        searchVC.searchBar.placeholder = "Search..."
        searchVC.searchBar.delegate = self
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    private func fetchData() {
        
        DatabaseManager.shared.explorePosts { [weak self] links in
            DispatchQueue.main.async {
                self?.links = links
                self?.collectionView.reloadData()
            }
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        
     
            guard let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
                  let query = searchController.searchBar.text,
                  !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }

            DatabaseManager.shared.findUsers(with: query) { results in
                DispatchQueue.main.async {
                    resultsVC.update(with: results)
                }

//            guard let resultsVC = searchController.searchResultsController as? SearchResultsLinkViewController,
//                  let query = searchController.searchBar.text,
//                  !query.trimmingCharacters(in: .whitespaces).isEmpty else {
//                return
//            }
//
//            DatabaseManager.shared.findLinks(with: query) { results in
//                DispatchQueue.main.async {
//
//                print("These are the results: \(results)")
//                resultsVC.update(with: results)
//
//                }
            }
        }
     
}

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return links.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCollectionViewCell.identifier,
            for: indexPath
        ) as? ExploreCollectionViewCell else {
            fatalError()
        }
        let model = links[indexPath.row]
        cell.configure(postString: model.link.postUrlString, iconString: model.link.linkTypeImage, nameOfLink: model.link.linkTypeName)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let model = links[indexPath.row]
        let vc = PostLinkViewController(link: model.link, owner: model.user.username)
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true, completion: nil)
//        let vc = PostViewController(post: model.post, owner: model.user.username)
//        navigationController?.pushViewController(vc, animated: true)
    }
}



extension ExploreViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewController(_ vc: SearchResultsViewController, didSelectResultWith user: User) {
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
}


//extension ExploreViewController: UISearchBarDelegate {
//  func searchBar(_ searchBar: UISearchBar,
//      selectedScopeButtonIndexDidChange selectedScope: Int) {
//
//
//    if searchBar.scopeButtonTitles?[selectedScope] == "Links" {
//        print("This is Link")
//        searchVC = UISearchController(searchResultsController: SearchResultsLinkViewController())
//        (searchVC.searchResultsController as? SearchResultsLinkViewController)?.delegate = self
//
//
//    } else if searchBar.scopeButtonTitles?[selectedScope] == "Users" {
//       print("This is Users")
//        searchVC = UISearchController(searchResultsController: SearchResultsViewController())
//        (searchVC.searchResultsController as? SearchResultsViewController)?.delegate = self
//
//    }
//
//}
//}


//extension ExploreViewController: SearchResultsLinkViewControllerDelegate {
//    func searchResultsViewController(_ vc: SearchResultsLinkViewController, didSelectResultWith links: LinkModel) {
//        let vc = PostLinkViewController(link: links, owner: links.user)
//        vc.modalPresentationStyle = .automatic
//        present(vc, animated: true, completion: nil)
//    }
    
    
//}
