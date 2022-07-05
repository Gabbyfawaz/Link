//
//  LinkPickerViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 01/04/2022.
//




//struct PrivateLink {
//    let title: String?
//    let desciption: String?
//    let date: TimeInterval?
//    let locationTitle: String?
//    let coordinates: CLLocationCoordinate2D?
//}
//
//import Foundation
//import UIKit
//import CoreLocation
//import MapKit
//
//final class LinkPickerViewController: UIViewController {
//
//    // MARK: PROPERTIES
//    
//    public var completion: ((PrivateLink?) -> Void)?
//    private var coordinates: CLLocationCoordinate2D?
//    private var mItem: MKMapItem?
////    private var observer: NSObjectProtocol?
////    private var hideObserver: NSObjectProtocol?
//    private var keyboardHeight: CGFloat?
////    private var isPickable = true
//   
//
//    private let privateLinkTitle: UITextField = {
//        let title = UITextField()
//        title.text = "Private Link"
//        title.textColor = .label
//        title.font = .systemFont(ofSize: 25, weight: .semibold)
//        title.isUserInteractionEnabled = false
//        return title
//    }()
//    
//    private let textview : UITextView = {
//        let tv = UITextView()
//        tv.textColor = .label
//        tv.textAlignment = .left
//        tv.font = .systemFont(ofSize: 18, weight: .semibold)
//        tv.text = "Desciption"
//        tv.backgroundColor = .secondarySystemBackground
//        tv.becomeFirstResponder()
//        return tv
//    }()
//    
//    private let cancelButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "multiply.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
//        button.tintColor = .label
//        return button
//    }()
//    
//    private let pencilButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
//        button.tintColor = .label
//        return button
//    }()
//    
//    private let timeButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
//        button.tintColor = .systemYellow
//        return button
//    }()
//    
//    private let locationButton: UIButton = {
//        let button = UIButton()
//        button.setImage( UIImage(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
//        button.tintColor = .systemYellow
//        return button
//    }()
//    
//    private let sendButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Send", for: .normal)
//        button.setTitleColor(.systemYellow, for: .normal)
//        button.backgroundColor = .black
//        return button
//    }()
//    
//    private var  stackView: UIStackView = {
//        let stack = UIStackView()
//        stack.layer.masksToBounds = true
//        stack.axis = .vertical
//        stack.alignment = .fill
//        stack.distribution = .fillEqually
//        stack.spacing = 20
//        stack.backgroundColor = .systemBackground
//        return stack
//    }()
//    
//    private let datePicker: UIDatePicker = {
//        let  picker = UIDatePicker()
//        picker.minimumDate = Date()
//        picker.preferredDatePickerStyle = .inline
//        picker.isHidden = true
//        picker.backgroundColor = .systemBackground
//        picker.layer.cornerRadius = 10
//        picker.layer.masksToBounds = true
//        return picker
//    }()
//    
//    private let blurEffectView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .secondarySystemBackground
//        view.isHidden = true
//        return view
//    }()
//
//    //MARK: LIFESTYLE
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .systemBackground
//        view.addSubview(privateLinkTitle)
//        view.addSubview(textview)
//        view.addSubview(sendButton)
//        view.addSubview(pencilButton)
//        view.addSubview(stackView)
//        view.addSubview(cancelButton)
//        stackView.addArrangedSubview(timeButton)
//        stackView.addArrangedSubview(locationButton)
//        pencilButton.addTarget(self, action: #selector(didTapPencil), for: .touchUpInside)
//        timeButton.addTarget(self, action: #selector(didTapTime), for: .touchUpInside)
//        locationButton.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
//        view.insertSubview(datePicker, at: 6)
////        view.addSubview(datePicker)
//        view.insertSubview(blurEffectView, at:  5)
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillShow),
//            name: UIResponder.keyboardWillShowNotification,
//            object: nil
//        )
//        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBlurView))
//        blurEffectView.addGestureRecognizer(tap)
//        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
//        cancelButton.addTarget(self, action: #selector(didCancelTapped), for: .touchUpInside)
//    }
//
//    
//    //MARK: ACTIONS
//    
//
//    @objc func keyboardWillShow(_ notification: Notification) {
//        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
//            self.keyboardHeight = keyboardHeight
//            
//            self.view.frame =  CGRect(x:0 ,
//                                      y: self.view.bottom-225-keyboardHeight,
//                                      width: self.view.bounds.width,
//                                      height: 225+keyboardHeight)
//        }
//       
//    }
//    
//
//    @objc func didTapPencil() {
//        privateLinkTitle.becomeFirstResponder()
//        privateLinkTitle.isUserInteractionEnabled = true
//    }
//    
//    @objc func didTapBlurView() {
//        datePicker.isHidden = true
//        blurEffectView.isHidden = true
//    }
//    
//    @objc func didTapTime() {
//        datePicker.isHidden = false
//        blurEffectView.isHidden = false
//    }
//    
//    @objc func didCancelTapped() {
//        dismiss(animated: true , completion: nil)
//    }
//    
//    @objc func didTapLocation() {
//        let vc = SearchResultTableViewController()
//        vc.completion = { [weak self ] mItem in
//            self?.dismiss(animated: true) {
//                let alert = UIAlertController(title: "Saved", message: "", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                self?.present(alert, animated: true, completion: nil)
//            
//                self?.coordinates = mItem?.placemark.coordinate
//                self?.mItem = mItem
//                print(self?.coordinates)
//            }
//            
//           
//        }
//        
//        let navVC = UINavigationController(rootViewController: vc)
//        present(navVC, animated: true)
//    }
//    
//    @objc func sendButtonTapped() {
////        guard let coordinates = coordinates else {
////            return
////        }
//        navigationController?.popViewController(animated: true)
//        
//        guard let title = privateLinkTitle.text else {
//            let alert = UIAlertController(title: "Try Again", message: "", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//            present(alert, animated: true)
//            return
//        }
//        
//        if title != "Private Link" {
//            let description = textview.text ?? ""
//            let coordinates = self.coordinates
//            let locationTitle = self.mItem?.name ?? ""
//            let pickerDate = datePicker.date.timeIntervalSince1970
//            let privateLink = PrivateLink(title: title, desciption: description, date: pickerDate, locationTitle: locationTitle, coordinates: coordinates)
//            completion?(privateLink)
//            dismiss(animated: true)
//        }
//       
//    }
//
//   
//    //MARK: LAYOUT SUBVIEWS
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
////        map.frame = view.bounds
//         
//        
////        self.view.frame =  CGRect(x:0 ,
////                                  y: self.view.bottom-200,
////                                  width: self.view.bounds.width-(keyboardHeight ?? 0),
////                                  height: 200)
//        
//        
//        privateLinkTitle.sizeToFit()
//        privateLinkTitle.frame =  CGRect(x: 20 ,
//                                         y: view.safeAreaInsets.top+10,
//                                         width: privateLinkTitle.width,
//                                         height: privateLinkTitle.height)
//        
//        pencilButton.frame = CGRect(x: privateLinkTitle.right+5, y: 10, width: 25, height: 25)
//        
//        textview.frame =  CGRect(x: 20 ,
//                                 y: privateLinkTitle.bottom+20,
//                                 width: view.width-100,
//                                  height: 100)
//        
//        sendButton.frame = CGRect(x: 20,
//                                  y: textview.bottom+10,
//                                  width: 80,
//                                  height: 35)
//        
//        
//        stackView.frame = CGRect(x: textview.right+10,
//                                 y: privateLinkTitle.bottom+35,
//                                 width: 25,
//                                 height: 70)
//        
//        datePicker.frame = CGRect(x: 90,
//                                  y: 5,
//                                  width: view.width-180,
//                                  height: view.width-200)
//        blurEffectView.frame = view.bounds
//        
//        cancelButton.frame = CGRect(x: view.width-30,
//                                    y: view.safeAreaInsets.top+10,
//                                    width: 20,
//                                    height: 20)
//
//    }
//    
//    
////    private func observeKeyboardChange() {
////        observer = NotificationCenter.default.addObserver(
////            forName: UIResponder.keyboardWillChangeFrameNotification,
////            object: nil,
////            queue: .main
////        ) { notification in
////            guard let userInfo = notification.userInfo,
////                  let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
////                return
////            }
////
////            UIView.animate(withDuration: 0.2) {
////
////                self.view.frame =  CGRect(x:0 ,
////                                          y: self.view.bottom-200-height,
////                                          width: self.view.bounds.width,
////                                          height: 200)
////
//////                self.view.frame.origin.y -= (height)
////            }
////
////        }
//
////        hideObserver = NotificationCenter.default.addObserver(
////            forName: UIResponder.keyboardWillHideNotification,
////            object: nil,
////            queue: .main
////        ) { _ in
////
////            UIView.animate(withDuration: 0.2) {
////                self.view.frame =  CGRect(x:0 ,
////                                          y: self.view.bottom-200,
////                                          width: self.view.bounds.width,
////                                          height: 200)
//////                self.view.frame.origin.y = 0
////            }
////
////
////        }
////    }
//    
//}
