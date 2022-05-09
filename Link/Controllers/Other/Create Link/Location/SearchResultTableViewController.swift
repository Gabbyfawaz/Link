//
//  SearchResultTableViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 06/12/2021.
//

import UIKit
import CoreLocation
import MapKit


protocol SearchResultTableViewControllerDelegate: AnyObject {
    func searchResultTableViewControllerDismiss(_ vc: SearchResultTableViewController, place: MKMapItem?)
}

class SearchResultTableViewController: UITableViewController {
    
    weak var delegate: SearchResultTableViewControllerDelegate?
    
    private enum SegueID: String {
        case showDetail
        case showAll
    }
    
    private enum CellReuseID: String {
        case resultCell
    }
    
    private var places: [MKMapItem]? {
        didSet {
            tableView.reloadData()
            viewAllButton.isEnabled = places != nil
        }
    }
    
    private var selectedMapItem: MKMapItem?
    public var completion: ((MKMapItem?) -> Void)?
    private var suggestionController = SuggestionsTableViewController()
    private var searchController =  UISearchController()
    
    private var viewAllButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        return button
    }()

//    @IBOutlet private var viewAllButton: UIBarButtonItem!
    
    private let locationManager = CLLocationManager()
    private var currentPlacemark: CLPlacemark?
    private var boundingRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    private var foregroundRestorationObserver: NSObjectProtocol?
    private var place: MKMapItem?
    
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
        }
    }
    
//    private let arrayOfImage: [UIImage]
//    private let iconImage: UIImage
//    private let caption: String
//    private let category: String
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        if navigationController?.viewControllers.count == 1 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), style: .done, target: self, action: #selector(self.didTapCancel))
            
            navigationItem.rightBarButtonItem?.tintColor = .secondarySystemBackground
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        suggestionController = SuggestionsTableViewController(style: .grouped)
        suggestionController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
        
//        let name = UIApplication.willEnterForegroundNotification
//        foregroundRestorationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { [unowned self] (_) in
//            // Get a new location when returning from Settings to enable location services.
//            self.requestLocation()
//        })
       
        
        self.requestLocation()
       
        title = "Choose Location"
        

        // Place the search bar in the navigation bar.
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search for places"
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = viewAllButton
        
        // Keep the search bar visible at all times.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellReuseID.resultCell.rawValue)
     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        requestLocation()
    }

    
    /// - Parameter suggestedCompletion: A search completion provided by `MKLocalSearchCompleter` when tapping on a search completion table row
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    /// - Parameter queryString: A search string from the text the user entered into `UISearchBar`
    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)

    }
    
    /// - Tag: SearchRequest
    private func search(using searchRequest: MKLocalSearch.Request) {
        // Confine the map search area to an area around the user's current location.
        searchRequest.region = boundingRegion
        
        // Include only point of interest results. This excludes results based on address matches.
        searchRequest.resultTypes = .address
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil else {
                self.displaySearchError(error)
                return
            }
            
            self.places = response?.mapItems
           
            // Used when setting the map's region in `prepareForSegue`.
            if let updatedRegion = response?.boundingRegion {
                self.boundingRegion = updatedRegion
            }
           
            
            delegate?.searchResultTableViewControllerDismiss(self, place: response?.mapItems.first)
            completion?(response?.mapItems.first)
           
//            if navigationController?.viewControllers.count == 1 {
//                let alert = UIAlertController(title: "Saved", message: "Location saved", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
//                    delegate?.searchResultTableViewControllerDismiss(self, place: response?.mapItems.first)
//
//                }))
//                present(alert, animated: true, completion: nil)
//
//                let secondsToDelay = 2.0
//                DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
//                    dismiss(animated: true, completion: nil)
//                }
//
//            }
            
        }
    }
    
    private func displaySearchError(_ error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "Could not find any places.", message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
        
    @objc func didTapCancel() {
            dismiss(animated: true, completion: nil)
        }
}

// MARK: - Location Handling

extension SearchResultTableViewController {
    private func requestLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            displayLocationServicesDisabledAlert()
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func displayLocationServicesDisabledAlert() {
        let message = NSLocalizedString("LOCATION_SERVICES_DISABLED", comment: "Location services are disabled")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: "OK alert button"), style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayLocationServicesDeniedAlert() {
        let message = NSLocalizedString("LOCATION_SERVICES_DENIED", comment: "Location services are denied")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        let settingsButtonTitle = NSLocalizedString("BUTTON_SETTINGS", comment: "Settings alert button")
        let openSettingsAction = UIAlertAction(title: settingsButtonTitle, style: .default) { (_) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                // Take the user to the Settings app to change permissions.
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelButtonTitle = NSLocalizedString("BUTTON_CANCEL", comment: "Location denied cancel button")
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(openSettingsAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension SearchResultTableViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemark, error) in
            guard error == nil else { return }
            
            self.currentPlacemark = placemark?.first
            self.boundingRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 12_000, longitudinalMeters: 12_000)
            self.suggestionController.updatePlacemark(self.currentPlacemark, boundingRegion: self.boundingRegion)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedAlways:
                return
            case .authorizedWhenInUse:
                return
            case .denied:
                return
            case .restricted:
                locationManager.requestWhenInUseAuthorization()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default:
                locationManager.requestWhenInUseAuthorization()
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle any errors returned from Location Services.
        print("error:: \(error.localizedDescription)")
    }
    
 
    
}

// MARK: - UITableViewDataSource

extension SearchResultTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseID.resultCell.rawValue, for: indexPath)
        if let mapItem = places?[indexPath.row] {
            cell.textLabel?.text = mapItem.name
            cell.detailTextLabel?.text = mapItem.placemark.formattedAddress
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var header = NSLocalizedString("SEARCH_RESULTS", comment: "Standard result text")
        if let city = currentPlacemark?.locality {
            let templateString = NSLocalizedString("SEARCH_RESULTS_LOCATION", comment: "Search result text with city")
            header = String(format: templateString, city)
        }
        
        return header
    }
    

    
}

// MARK: - UITableViewDelegate

extension SearchResultTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == suggestionController.tableView, let suggestion = suggestionController.completerResults?[indexPath.row] {
            searchController.isActive = false
            searchController.searchBar.text = suggestion.title
            search(for: suggestion)
           
        }
        
        if !(navigationController?.viewControllers.count == 1) {
            let vc = MapViewController(mapItems: places, boundingRegion: boundingRegion)
            navigationController?.pushViewController(vc, animated: true)
        }

        
//        if navigationController?.viewControllers.count == 1 {
//            let alert = UIAlertController(title: "Saved", message: "Location saved", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
//                self.delegate?.searchResultTableViewControllerDismiss(self, place: self.places?.first)
//                self.dismiss(animated: true, completion: nil)
//
//            }))
//
//         present(alert, animated: true)
//        }
//
        
       
    }
}

// MARK: - UISearchBarDelegate

extension SearchResultTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // The user tapped search on the `UISearchBar` or on the keyboard. Since they didn't
        // select a row with a suggested completion, run the search with the query text in the search field.
        search(for: searchBar.text)
    }
}

