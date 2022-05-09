//
//  LinkCameraViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import AVFoundation
import PhotosUI
import Photos
import JGProgressHUD
import MapKit

class LinkCameraViewController: UIViewController, UIGestureRecognizerDelegate {
    
// MARK: PROPERTIES
    private var identity = CGAffineTransform.identity
    private let quickLinkSticker = QuickLinkSticker()
    private let spinner = JGProgressHUD(style: .dark)
    private let session = AVCaptureSession()
    private var cameraImage: UIImage?
    private var output = AVCapturePhotoOutput()
    private var observer: NSObjectProtocol?
    private let panGesture = UIPanGestureRecognizer()
//    private var captureSession: AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let cameraView = UIView()
    private let imageView:  UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private var place: MKMapItem?
    private var pickerDate: Date?
    private var textHeightConstraint: NSLayoutConstraint?
    
//    private var results: [PHPickerResult]?
    private let sessionQueue = DispatchQueue(label: "session queue")
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!

    private var didCameraFlip = false
    private var PhotoArray = [UIImage]()
//    private var PhotoArray: [(image: UIImage, indexOf: Int)] = []
    static var staticPhotoArray = [UIImage]()
    private var xPosition = CGFloat(0)
    private var yPosition = CGFloat(0)

    private let shutterButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = nil
        button.isHidden = false
        return button
    }()

    private let photoPickerButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)),for: .normal)
        button.isHidden = false
        return button
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.isHidden = true
        button.setImage(UIImage(systemName: "arrow.forward.square.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)),
                        for: .normal)
        button.insetsLayoutMarginsFromSafeArea = true
        button.tintColor = .white
        return button
    }()
    
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.text = "Main"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    private let quickLabel: UILabel = {
        let label = UILabel()
        label.text = "Quick"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    
    private var  mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.isHidden = true 
        return stack
    }()
    
    private var quickStackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        return stack
    }()
    
    
    private let flipCamera: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.isHidden = false
        button.setImage(UIImage(systemName: "camera.rotate.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)),
                        for: .normal)
        button.tintColor = .white
        return button
    }()
    
    
    private let friendsButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "person.2.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)),
                        for: .normal)
        button.tintColor = .white
        return button
    }()
    
    
    private let linkButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "link", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)),
                        for: .normal)
//        button.setTitle("Quick", for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private var  stackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.isHidden = true
//        stack.layer.cornerRadius = 17.5
        return stack
    }()
    
    
    private let picker: UIDatePicker = {
        let  picker = UIDatePicker()
        picker.minimumDate = Date()
        picker.preferredDatePickerStyle = .inline
        picker.isHidden = true
        picker.backgroundColor = .systemBackground
        picker.layer.cornerRadius = 10
        picker.layer.masksToBounds = true
        return picker
    }()
    
    private let blurEffectView: UIView = {
        let view = UIView()
        view.backgroundColor = .none
        view.isHidden = true
        return view
    }()
   
    
    // MARK: LIFECYCLE
    
    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          previewLayer.frame = self.cameraView.bounds
          session.startRunning()
      }

    override func viewDidLoad() {
        super.viewDidLoad()
      
       addAllSubviews()
        quickLinkSticker.isHidden = true
        quickLinkSticker.delegate = self
        configureNavBar()
        checkCameraPermission()
        
        picker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        blurEffectView.addGestureRecognizer(tap)
        
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        photoPickerButton.addTarget(self, action: #selector(addImagesClicked), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        flipCamera.addTarget(self, action: #selector(didFlipCamera), for: .touchUpInside)
//        segueToLinkEditVC()

        friendsButton.addTarget(self, action: #selector(didTapFriendButton), for: .touchUpInside)
        linkButton.addTarget(self, action: #selector(didTapLinkButton), for: .touchUpInside)
        let panGesture =  UIPanGestureRecognizer(target: self, action: #selector(LinkCameraViewController.draggedView(_:)))
          quickLinkSticker.isUserInteractionEnabled = true
        quickLinkSticker.addGestureRecognizer(panGesture)
        quickLinkSticker.translatesAutoresizingMaskIntoConstraints = true
       
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap2.cancelsTouchesInView = false
        imageView.addGestureRecognizer(tap2)

//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scale))
//        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate))
//        pinchGesture.delegate = self
//        rotationGesture.delegate = self
//        view.addGestureRecognizer(pinchGesture)
//        view.addGestureRecognizer(rotationGesture)
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
    }
    
     /// addsubviews:
    
    private func addAllSubviews() {
        view.addSubview(cameraView)
        view.addSubview(shutterButton)
        view.addSubview(photoPickerButton)
        view.addSubview(imageView)
        view.addSubview(doneButton)
        view.addSubview(flipCamera)
        view.addSubview(blurEffectView)
        view.addSubview(picker)
        view.addSubview(quickLinkSticker)
        view.addSubview(stackView)
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(doneButton)
        mainStackView.addArrangedSubview(mainLabel)
        view.addSubview(quickStackView)
        quickStackView.addArrangedSubview(linkButton)
        quickStackView.addArrangedSubview(quickLabel)
        stackView.addArrangedSubview(friendsButton)
        stackView.addArrangedSubview(quickStackView)
    }

    // MARK: LAYOUT SUBVIEWS
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cameraView.frame = view.frame
        previewLayer.frame = view.frame
        imageView.frame = view.frame

        let buttonSize: CGFloat = view.width/5
        shutterButton.frame = CGRect(
            x: (view.width-buttonSize)/2,
            y: view.safeAreaInsets.top + view.width + 200,
            width: buttonSize,
            height: buttonSize
        )
        shutterButton.layer.cornerRadius = buttonSize/2

        photoPickerButton.frame = CGRect(x: (shutterButton.left - (buttonSize/1.5))/2,
                                         y: shutterButton.top + ((buttonSize/1.5)/2),
                                         width: buttonSize/1.5,
                                         height: buttonSize/1.5)
        flipCamera.frame = CGRect(x: view.width - (buttonSize/1.5)*2,
                                         y: shutterButton.top + ((buttonSize/1.5)/2),
                                         width: buttonSize/1.5,
                                         height: buttonSize/1.5)
        
        mainStackView.frame = CGRect(x: view.width-buttonSize+10,
                                  y: view.height-buttonSize-20,
                                  width: buttonSize/1.5,
                                  height: buttonSize/1.5)
        
        stackView.frame = CGRect(x: 20,
                                 y: view.height-buttonSize-20,
                                 width: (buttonSize/1.5)*2,
                                 height: (buttonSize/1.5))
      
        quickLinkSticker.frame = CGRect(x: (view.width-160)/2 + xPosition, y: (view.height-140)/2 + yPosition, width: 160, height: 140)
        picker.frame = CGRect(x: (view.width-picker.width)/2, y:  (view.height-picker.height)/2, width: picker.width, height: picker.height)

        
    }
    
    // MARK: ACTIONS FOR VIEW
    private func configureNavBar() {
        navigationController?.navigationBar.tintColor = .label
        view.backgroundColor = .systemBackground

        let button =  UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        button.tintColor = .white
        navigationItem.leftBarButtonItem = button
    }
    

    ///Draggable View
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubviewToFront(quickLinkSticker)
        let translation = sender.translation(in: self.view)
        xPosition = translation.x
        yPosition = translation.y
        quickLinkSticker.center = CGPoint(x: quickLinkSticker.center.x + translation.x, y: quickLinkSticker.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
    }
    
    
    // MARK: ACTIONS FOR QUICK LINK:
    @objc func didAddButton() {
        self.quickLinkSticker.isHidden = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextView) -> Bool {
        quickLinkSticker.textfield.resignFirstResponder()
        return true
    }

    
    @objc func didTapFriendButton() {
        let vc = ShareLinksViewController()
        present(vc, animated: true, completion: nil)
    }
    
    
    private func createNewPostID() -> String? {
        let timeStamp = Date().timeIntervalSince1970
        let randomNumber = Int.random(in: 0...1000)
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return nil
        }

        return "link_\(username)_\(randomNumber)_\(timeStamp)"
    }
    
    @objc func didTapLinkButton() {

        guard let username = UserDefaults.standard.string(forKey: "username"),
              let id = createNewPostID()
        else {
            fatalError()
        }
        let height = quickLinkSticker.textfield.contentSize.height
        let xPosition = quickLinkSticker.center.x-80
        let yPosition = quickLinkSticker.center.y-70
        let locationName = place?.name
        let latitude = place?.placemark.coordinate.latitude
        let longitude = place?.placemark.coordinate.longitude
        let coordinate = Coordinates(latitude: latitude, longitude: longitude)
        let timeInterval = pickerDate?.timeIntervalSince1970
        let data = imageView.image?.pngData()
        let date = Date().timeIntervalSinceReferenceDate
        let text = quickLinkSticker.textfield.text
        if text == "Link Title" || text == "" {
            let alert = UIAlertController(title: "Please enter text in sticker", message: "Tap the add button to add sticker", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        
        linkButton.isUserInteractionEnabled = false
        linkButton.alpha = 0.5
        quickLabel.alpha = 0.5
        StorageManager.shared.uploadQuickLink(data: data, id: id) { url in
            guard let imageUrlString = url?.absoluteString else {
                return
            }
            
            
            let quickLink = QuickLink(id: id, username: username, timestamp: timeInterval, imageUrlString: imageUrlString, locationTitle: locationName, locationCoodinates: coordinate, info: text, xPosition: xPosition, yPosition: yPosition, height: height, date: date, joined: [])
            
            DatabaseManager.shared.createQuickLink(quickLink: quickLink) { success in
                if success {
                    self.spinner.dismiss(animated: false )
                    self.tabBarController?.tabBar.isHidden = false
                    self.tabBarController?.selectedIndex = 0
                    NotificationCenter.default.post(name: .didPostLinkOnMap,
                                                    object: nil)
                    self.navigationController?.popToRootViewController(animated: false)
                } else {
                    print("Error not sucessful")
                }
                
            }
        }
        
        
        
        print("Did tap link button")
    }
    
    @objc func didTapView() {
        picker.isHidden = true
        blurEffectView.isHidden = true
        quickLinkSticker.isHidden = false
    }
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        self.pickerDate = picker.date
        print("current: \(picker.date)")
       }
    
    
    
    //MARK: ACTIONS FOR CAMERA
    
    private func setUpCamera() {
        
           
            do {
                if let  defaultVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .unspecified) {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
                    
                    if session.canAddInput(videoDeviceInput) {
                        session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    }
                }
               
            } catch {
                print(error)
            }
            
            /// takes the ouput
            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            /// Layer
//        if ((previewLayer.connection?.isVideoMirrored) != nil) {
//            previewLayer.connection?.automaticallyAdjustsVideoMirroring = false
//
//        }
        previewLayer.connection?.isVideoMirrored = false
            previewLayer.session = session
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer)

            session.startRunning()
        
    }
    
    /// DID TAKE PHOTO (PRESSED SHUTTER BUTTON)
    
    @objc func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(),
                            delegate: self)
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .notDetermined:
            // request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .authorized:
            setUpCamera()
        case .restricted, .denied:
            break
        @unknown default:
            break
        }
    }
    
    /// DID FLIP CAMERA
    
    @objc func didFlipCamera() {
        switchCamera()
        print("Camera has been flipped ")
    }
    
    func switchCamera() {
        
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
            let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera],mediaType: .video, position: .front)
            var newVideoDevice: AVCaptureDevice? = nil
            switch currentPosition {
            case .unspecified, .front:
                newVideoDevice = backVideoDeviceDiscoverySession.devices.first
            case .back:
                newVideoDevice = frontVideoDeviceDiscoverySession.devices.first
            @unknown default:
                print("Unknown capture position. Defaulting to back, dual-camera.")
                newVideoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            }
              
           
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    
            
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
//
                        
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    guard let connection = self.output.connection(with: .video) else { return }
                    connection.isVideoMirrored = newVideoDevice?.position == .front
                    self.output.maxPhotoQualityPrioritization = .quality
                    self.session.commitConfiguration()
                    
                  } catch {
                    print(error)
                  }
            
            }
      
        }
        

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

       
    }
    
    // MARK: FUNCTIONS TO ACCESS GALLERY AND FETCH IMAGES
    
    @objc private func addImagesClicked() {
        PHPhotoLibrary.requestAuthorization{ status in
            
            if status == PHAuthorizationStatus.authorized {
                DispatchQueue.main.async {
                    
                    self.showPhotoLibrary()
                }
            } else {
                // should show a pop up
                // suggest going to settings to change the access to library from there
                print("No access")
            }

            
        }
    }
    
    private func showPhotoLibrary() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .current
//        configuration.filter = .videos
        configuration.selectionLimit = 5
        configuration.selection = .ordered
        if #available(iOS 15, *) {
            configuration.selection = .ordered
        } else {
            // Fallback on earlier versions
        }
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
//        picker.modalPresentationStyle = .fullScreen
//        picker.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(didPressAdd))
        present(picker, animated: true, completion: nil)
        
        
    }
    
    
    @objc func didTapDone() {
        
        if self.PhotoArray.count == 0 {
            guard let image = self.cameraImage else {
                fatalError("No image was out returned from the camera's output")
            }
            let vc = PostEditViewController(arrayOfImage: [image])
            navigationController?.pushViewController(vc, animated: false)
//            showEditPhoto(image: image)
        } else if self.PhotoArray.count > 0 {
            let image = self.PhotoArray[0]
             let vc = PostEditViewController(arrayOfImage: [image])
            navigationController?.pushViewController(vc, animated: false)
            //            showEditPhoto(image: image)
        }

    }

    
    //MARK: CONFIGURE VIEW AFTER CAMERA OUTPUT
    
    private func configureViewAfterCameraOuput(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        photoPickerButton.isHidden = true
        shutterButton.isHidden = true
        flipCamera.isHidden = true
        cameraView.isHidden = true
        doneButton.isHidden = false
        stackView.isHidden = false
        mainStackView.isHidden = false
        navigationItem.rightBarButtonItem =  UIBarButtonItem(
            image: UIImage(systemName: "plus.app.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)),
            style: .done,
            target: self,
            action: #selector(didAddButton))
        navigationItem.rightBarButtonItem?.tintColor = .white
        
       
    }
    

    @objc func didTapClose() {
        // remove the imageiew
//        imageView.transform.rotated(by)
        if cameraView.isHidden == true  {
            imageView.isHidden = true
            quickLinkSticker.isHidden = true
            picker.isHidden = true
            stackView.isHidden = true
            mainStackView.isHidden = true
            photoPickerButton.isHidden = false
            shutterButton.isHidden = false
            cameraView.isHidden = false
            flipCamera.isHidden = false
            navigationItem.rightBarButtonItem = nil
        } else if cameraView.isHidden == false  {
            //then lastly remove the view controller
            navigationController?.navigationBar.tintColor = .black
            navigationController?.popViewController(animated: true)
            tabBarController?.selectedIndex = 0
            tabBarController?.tabBar.isHidden = false
        }
       
        
        

    }
    

    
}



extension LinkCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }
        
        
        self.cameraImage = image
//        session.stopRunning()
        configureViewAfterCameraOuput(image: image)
//        plusButton.isHidden = false
    }

    private func showEditPhoto(image: UIImage) {
        guard let resizedImage = image.sd_resizedImage(
            with: CGSize(width: view.width, height: view.height + view.safeAreaInsets.top),
            scaleMode: .aspectFill
        ) else {
            return
        }
        
        
        let vc = PostEditViewController(arrayOfImage: [resizedImage])
//        if #available(iOS 14.0, *) {
//            vc.navigationItem.backButtonDisplayMode = .minimal
//        }
        navigationController?.pushViewController(vc, animated: false)

    }
}

 // MARK: PICKER INFO FROM GALLERY

extension LinkCameraViewController: PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        let group = DispatchGroup()
//        self.results = results
        self.PhotoArray = [UIImage]()
        LinkCameraViewController.staticPhotoArray = [UIImage]()
        
        spinner.show(in: view)
        results.forEach({ result in
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self ] reading , error in
                defer{
                    group.leave()
                }
                guard let self = self else {
                    return 
                }
                
        
                guard var image = reading as? UIImage, error == nil else {
                    fatalError("Could not convert the image")
                }
                image = image.fixOrientation()
                
                self.PhotoArray.append(image)
                
//                self.PhotoArray.insert((image: image, indexOf: index), at: index)
//                print("This is the image: \(self.PhotoArray[index].image) at \(self.PhotoArray[index].indexOf)")
//                index += 1
                
       
            }
        })
     
        group.notify(queue: .main) {
            print("The count for this group is: \(self.PhotoArray)")
            self.spinner.dismiss(animated: true)
//            let reverseImages = Array(self.PhotoArray.reversed())
            let images = self.PhotoArray
            LinkCameraViewController.staticPhotoArray = images
            
            if self.PhotoArray.count == 1 {
                
//                self.imageView.image = self.PhotoArray[0]
                self.configureViewAfterCameraOuput(image: self.PhotoArray[0])
            } else if self.PhotoArray.count>1 {
                let vc = PostEditViewController(arrayOfImage: images)
                self.navigationController?.pushViewController(vc, animated: true)
                print("I'll fix this later")
            }
        }
  
        print("Finished all items")
    
        
        
        
    }
    
    
    
    
    

}

extension LinkCameraViewController: QuickLinkStickerDelegate {
    
    func quickLinkStickerDelegateDidButton(_ view: QuickLinkSticker, isJoined: Bool) {
        //

    }
    
    func quickLinkStickerDelegateDidTapClock(_ view: QuickLinkSticker) {
        //present picker controller
        
        
        view.endEditing(true)
        

//        let alert = UIAlertController(title: "Select Date", message: "Pick a date for quick link", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in

            self.picker.isHidden = false
            self.blurEffectView.isHidden = false
            self.quickLinkSticker.isHidden = true
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
//        present(alert, animated: true )
    }
    
    func quickLinkStickerDelegateDidTapLocation(_ view: QuickLinkSticker) {
        // present the search location thing
        
        
        view.endEditing(true)
        let vc = SearchResultTableViewController()
         let navVC = UINavigationController(rootViewController: vc)
         vc.delegate = self
        self.present(navVC, animated: true )
//        let alert = UIAlertController(title: "Select Location", message: "Pick a date for quick link", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
//
//
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
//        present(alert, animated: true )
    }
    
    func quickLinkStickerDelegateDidTapPeople(_ view: QuickLinkSticker) {
        // alert says shows users that join!
        
        
        view.endEditing(true)
//        let alert = UIAlertController(title: "Friends Joining", message: "You will see users who join the event here", preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        present(alert, animated: true)
        
    }
    
    
    func quickLinkStickerDelegateDidTapCancel(_ view: QuickLinkSticker) {
        quickLinkSticker.isHidden = true
    }
    
    
}

extension LinkCameraViewController: SearchResultTableViewControllerDelegate {
    
    func searchResultTableViewControllerDismiss(_ vc: SearchResultTableViewController, place: MKMapItem?) {
        self.place = place
//        print("the places: \(place)")
//        dismiss(animated: true, completion: nil)
    }
    
    
}

//@objc func scale(_ gesture: UIPinchGestureRecognizer) {
//
////                if gesture.state == .changed {
//////                    imageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
////                    imageView.transform = identity.scaledBy(x: gesture.scale, y: gesture.scale)
////                }
//
//    switch gesture.state {
//        case .began:
//            identity = imageView.transform
//        case .changed,.ended:
//            imageView.transform = identity.scaledBy(x: gesture.scale, y: gesture.scale)
//        case .cancelled:
//            break
//        default:
//            break
//        }
//    }
//    @objc func rotate(_ gesture: UIRotationGestureRecognizer) {
//
//        imageView.transform = imageView.transform.rotated(by: gesture.rotation)
//    }
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//   func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
//    return true
//}
//
//   func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
//    return true
//}
//func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//    return true
//}
