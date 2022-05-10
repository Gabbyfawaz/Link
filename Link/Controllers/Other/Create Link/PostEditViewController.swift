//
//  PostEditViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import CoreImage
import UIKit
import CoreLocation

protocol PostEditViewControllerDelegate: AnyObject {
    func postEditViewControllerImageArray(_ vc: PostEditViewController, array: [UIImage])
}

class PostEditViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - Properties
    
    weak var delegate: PostEditViewControllerDelegate?
    private var typeOfLink: String?
    static var staticCaption: String?
    static var staticIconImage: UIImage?
    static var staticImageArray = [UIImage]()
    public var pickerImage: UIImage?
    private var arrayOfImage: [UIImage]
    private var orginalArrayOfImages: [UIImage]
    private var index = 0
    private var imageCell: FiltersCollectionViewCell?
    private var keyboardHeight: CGFloat?
    
     public var iconImageView: UIImageView = {
        let image = UIImageView()
        image.isUserInteractionEnabled = true
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 35
        image.backgroundColor = UIColor(white: 1, alpha: 0.2)
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.label.cgColor
        return image
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.text = "CHOOSE ICON"
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.right.circle.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 1, alpha: 0.8)
        return button
    }()
    
    private let leftButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.left.circle.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(white: 1, alpha: 0.8)
        return button
    }()
    
    private var filters = ["Original", "Chrome", "Fade", "Mono", "Instant", "Noir", "Process", "Tonal", "Transfer"]
    
    
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let filterCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 150)
        layout.minimumInteritemSpacing = 10
//        layout.minimumLineSpacing = 10
//        layout.sectionInset = UIEdgeInsets(top: 1, left: 10, bottom: 1, right: 10)
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FiltersCollectionViewCell.self,
                                forCellWithReuseIdentifier: FiltersCollectionViewCell.identifier)
        return collectionView
    }()
    
    
    
    public let captionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Caption"
        tf.textColor = .label
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
//        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = .systemFont(ofSize: 21, weight: .light)
        return tf
    }()
    
//    private let lineView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        return view
//    }()
    


    
   
    //MARK: - Lifecycle
    
    
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
        
        configureNavBar()
        addSubviews()

        
        imageView.image = arrayOfImage[index]
        
        if arrayOfImage.count == 1 {
            rightButton.isHidden = true
            leftButton.isHidden = true
        }
        
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        

        rightButton.addTarget(self, action: #selector(didSwipeRight), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(didSwipeLeft), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        iconImageView.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap2)
        
        tap2.cancelsTouchesInView = false
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeRight.direction = .right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        
        swipeRight.direction = .right
        swipeLeft.direction = .left
        
        imageView.addGestureRecognizer(swipeLeft)
        imageView.addGestureRecognizer(swipeRight)
        

    }
    
    //MARK: - Init
    init(arrayOfImage: [UIImage]) {
        self.arrayOfImage = arrayOfImage
        self.orginalArrayOfImages = arrayOfImage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    //MARK: - LayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        
        imageView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: view.width+40
        )
        
        rightButton.frame = CGRect(x: view.width-rightButton.width-10,
                                   y: imageView.top+(view.width)/2,
                                   width: 40,
                                   height: 40)
        leftButton.frame = CGRect(x: imageView.left+5,
                                   y: imageView.top+(view.width)/2,
                                   width: 40,
                                   height: 40)
        iconImageView.frame = CGRect(x: 20,
                                     y: imageView.bottom+20,
                                     width: 70,
                                     height: 70)
        label.frame = CGRect(x: iconImageView.left+10,
                             y: iconImageView.top+10,
                             width: 50,
                             height: 50)
        
        captionTextField.frame = CGRect(x: iconImageView.right+20,
                               y: imageView.bottom+30,
                               width: view.width-60-70,
                               height: 50)
        captionTextField.addLine(position: .bottom, color: .label, width: 1 )
//        lineView.frame = CGRect(x: iconImageView.right+20,
//                                y: caption.bottom,
//                                width: view.width-60-iconImageView.width,
//                                height: 2)
//
        filterCollectionView.frame = CGRect(
            x: 0,
            y: iconImageView.bottom+20,
            width: view.width,
            height: 150
        )
        
      
        
    }
    
    //MARK: - ConfigureNavigationBar
    
    private func configureNavBar() {
        navigationController?.navigationBar.tintColor = .label
        title = "Edit Image"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(didTapNext))
        if #available(iOS 14.0, *) {
            navigationItem.backButtonDisplayMode = .minimal
        }
    }
    
    //MARK: - AddSubviews
    
    private func addSubviews() {
        view.addSubview(imageView)
        view.addSubview(filterCollectionView)
        view.addSubview(iconImageView)
        view.addSubview(label)
        view.addSubview(captionTextField)
        view.insertSubview(rightButton, at: 1)
        view.insertSubview(leftButton, at: 1)
//        view.addSubview(lineView)
    }
    
    //MARK: - Actions
    
    
    @objc func didSwipeRight() {
        
        if index < arrayOfImage.count-1 {
            self.index += 1
            imageView.image = arrayOfImage[index]
            filterCollectionView.reloadData()
        } else if index >= arrayOfImage.count-1 {
            index = 0
            imageView.image = arrayOfImage[index]
            filterCollectionView.reloadData()
        }
        
    }
    

    @objc func didSwipeLeft() {
//        var numberArray = arrayOfImage.count
        if index <= arrayOfImage.count-1 && index > 0{
            print("More than 0")
            index -= 1
            imageView.image = arrayOfImage[index]
            filterCollectionView.reloadData()
      
        } else if index <= 0 {
            print("Less than 0")
            index = arrayOfImage.count-1
            imageView.image = arrayOfImage[index]
            filterCollectionView.reloadData()
           
        }
    }
    
    
    
    @objc func didTapNext() {
        
        
        if let iconImage = iconImageView.image, let pickerImage = self.pickerImage {
            
            if iconImage == pickerImage {
                
                
                if let vcs = self.navigationController?.viewControllers {
                    let previousVC = vcs[vcs.count - 2]
                    if previousVC is FinalPageCreateLinkViewController {
                        PostEditViewController.staticIconImage = pickerImage
                        navigationController?.popViewController(animated: true)
                    } else if previousVC is LinkCameraViewController {
                        let vc = CategoryViewController()
        //                let vc = CategoryViewController(arrayOfImage: arrayOfImage, iconImage: pickerImage, caption: caption.text ?? "")
                        PostEditViewController.staticImageArray = arrayOfImage
                        PostEditViewController.staticCaption = captionTextField.text ?? ""
                        PostEditViewController.staticIconImage = pickerImage
                        navigationController?.pushViewController(vc, animated: true)
                    }
                    
                }
            }
            
        } else {
            let alert = UIAlertController(title: "Choose Icon", message: "Select Link Icon", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }

    }
    

    
    @objc func didTapImage() {
        print("Did tap this icon button sis")
        
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach a photo from",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }

    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

  
    //MARK: - CollectionView Delegate/Datasource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filters.count

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FiltersCollectionViewCell.identifier,
                for: indexPath
            ) as? FiltersCollectionViewCell else {
                fatalError()
            }

//            cell.configure(with: filters[indexPath.row])
            cell.configure(with: filters[indexPath.row], image: orginalArrayOfImages[index])
            return cell

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        

        let orginalImages = orginalArrayOfImages[index]
        
        switch filters[indexPath.row] {
        case "Original":
            let newImage = orginalImages
            imageView.image = newImage
            arrayOfImage[index] = newImage
        case "Chrome":
            let newImage = orginalImages.addFilter(filter: .Chrome)
            imageView.image = newImage
            arrayOfImage[index] = newImage
        case "Fade":
            let newImage = orginalImages.addFilter(filter: .Fade)
            imageView.image = newImage
            arrayOfImage[index] = newImage
        case "Mono":
            let newImage = orginalImages.addFilter(filter: .Mono)
            imageView.image = newImage
            arrayOfImage[index] = newImage
        case "Instant":
            let newImage = orginalImages.addFilter(filter: .Instant)
            imageView.image = newImage
            arrayOfImage[index] = newImage
        case "Noir":
            let newImage = orginalImages.addFilter(filter: .Noir)
            imageView.image = newImage
            arrayOfImage[index] = newImage
        case "Process":
            let newImage = orginalImages.addFilter(filter: .Process)
            imageView.image = newImage
            arrayOfImage[index] = newImage
        case "Tonal":
            let newImage = orginalImages.addFilter(filter: .Tonal)
            imageView.image = newImage
            arrayOfImage[index] = newImage
        case "Transfer":
            let newImage = orginalImages.addFilter(filter: .Transfer)
            imageView.image = newImage
            arrayOfImage[index] = newImage
        default:
            break
        }
        

    }
    
   
}

//MARK: - PickerView Delegate/Datasource

extension PostEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        label.isHidden = true
        iconImageView.image = image
        self.pickerImage = image
    
        
    }
}
    
