//
//  LinkCameraViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import AVFoundation
import Photos
import BSImagePicker

class LinkCameraViewController: UIViewController {

    private var output = AVCapturePhotoOutput()
    private var captureSession: AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let cameraView = UIView()
    
   private var SelectedAssets = [PHAsset]()
    private var PhotoArray = [UIImage]()
    

    private let shutterButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.label.cgColor
        button.backgroundColor = nil
        return button
    }()

    private let photoPickerButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30)),
                        for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
//        title = "Create Link"
        view.addSubview(cameraView)
        view.addSubview(shutterButton)
        view.addSubview(photoPickerButton)
        setUpNavBar()
        checkCameraPermission()
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        photoPickerButton.addTarget(self, action: #selector(addImagesClicked), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
        if let session = captureSession, !session.isRunning {
            session.startRunning()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession?.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraView.frame = view.bounds
        previewLayer.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: view.height
        )

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
    }
    
    @objc func addImagesClicked() {
    
        
        // create an instance
//        let vc = BSImagePickerViewController()
        
       let imagePicker = ImagePickerController()
        

        presentImagePicker(imagePicker, select: { (asset) in
            // User selected an asset. Do something with it. Perhaps begin processing/upload?
        }, deselect: { (asset) in
            // User deselected an asset. Cancel whatever you did when asset was selected.
        }, cancel: { (assets) in
            // User canceled selection.
        }, finish: { (assets) in
            // User finished selection assets.
            for i in 0..<assets.count
            {
                self.SelectedAssets.append(assets[i])
            
            }
            
            self.convertAssetToImages()
        })
    
        
    }
    
    func convertAssetToImages() -> Void {
            
            if SelectedAssets.count != 0{
                
                
                for i in 0..<SelectedAssets.count{
                    
                    let manager = PHImageManager.default()
                    let option = PHImageRequestOptions()
                    var thumbnail = UIImage()
                    option.isSynchronous = true
                    
                   
                    manager.requestImage(for: SelectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                        thumbnail = result!
                        
                    })
                    
                    let data = thumbnail.jpegData(compressionQuality: 0.7)
                    let newImage = UIImage(data: data!)
                  
                    
                    self.PhotoArray.append(newImage! as UIImage)
                    
                }
               
               // add images to collection view
                
                dismiss(animated: true, completion: {
                    let vc = PostEditViewController(arrayOfImage: self.PhotoArray)
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                
            }
            
            
            print("complete photo array \(self.PhotoArray)")
        }

    @objc func didTapPickPhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

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

    private func setUpCamera() {
        let captureSession = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            }
            catch {
                print(error)
            }

            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }

            // Layer
            previewLayer.session = captureSession
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer)

            captureSession.startRunning()
        }
    }

    @objc func didTapClose() {
        navigationController?.popViewController(animated: true)
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
    }

    private func setUpNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
    }
}

extension LinkCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        showEditPhoto(image: image)
    }
}

extension LinkCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }
        captureSession?.stopRunning()
        showEditPhoto(image: image)
    }

    private func showEditPhoto(image: UIImage) {
//        guard let resizedImage = image.sd_resizedImage(
//            with: CGSize(width: 640, height: 640),
//            scaleMode: .aspectFill
//        ) else {
//            return
//        }
//
//        let vc = PostEditViewController(image: resizedImage)
//        if #available(iOS 14.0, *) {
//            vc.navigationItem.backButtonDisplayMode = .minimal
//        }
//        navigationController?.pushViewController(vc, animated: false)

    }
}
