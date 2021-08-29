//
//  NameofLinkCollectionView.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/31.
//

import UIKit

import UIKit
import FirebaseAuth



final class NameofLinkCollectionView: UIView {

    //MARK: -  Properties
    
    private var isRequested = false
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .systemBackground
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
//        imageView.image?.withTintColor(.white)
        return imageView
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .systemBackground
//        imageView.image?.withTintColor(.white)
        return imageView
    }()

    private let typeOfLink: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        return label
    }()
    
    
    private var requestButtom: UIButton = {
       let button = UIButton()
       button.backgroundColor = .black
       button.setTitle("Request", for: .normal)
        button.setTitleColor(.white, for: .normal)
       button.layer.cornerRadius = 8
       return button
   }()
    
//    private let moreButton: UIButton = {
//        let button = UIButton()
//        button.tintColor = .label
//        let image = UIImage(systemName: "ellipsis",
//                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
//        button.setImage(image, for: .normal)
//        return button
//    }()

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = .systemBackground
        layer.masksToBounds = true
        layer.cornerRadius = 20
        addSubview(imageView)
        addSubview(typeOfLink)
        insertSubview(backgroundImageView, at: 0)
//        addSubview(requestButtom)
        requestButtom.addTarget(self, action: #selector(didTapRequest), for: .touchUpInside)
  
    
    }
    
    //MARK: - Actions
    
    @objc private func didTapProfileImage() {
        
   /// go to users page
    }
    
    @objc private func didTapRequest() {
       
       isRequested = !isRequested
       
//        if  Auth.auth().currentUser?.email == UserDefaults.standard.string(forKey: "email") {
//            requestButtom.setTitle("Repost", for: .normal)
//            requestButtom.backgroundColor = .systemBlue
//            requestButtom.addTarget(self, action: #selector(didTapRepost), for: .touchUpInside)
//        } else {
           if isRequested {
               requestButtom.setTitle("Requesting", for: .normal)
               requestButtom.backgroundColor = .lightGray
            requestButtom.layer.borderColor = UIColor.secondarySystemBackground.cgColor
//                requestButtom.layer.borderWidth = 3
               print(isRequested)
           } else {
               requestButtom.setTitle("Request", for: .normal)
               requestButtom.backgroundColor = .black
               print(isRequested)
           }
       
//       
//       delegate?.posterLinkCollectionViewCellDidTapRequest(self, index: index)
       
   }
    
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundImageView.frame = bounds
        
//        let imagePadding: CGFloat = 4
        let imageSize: CGFloat = height/4
        imageView.frame = CGRect(x: 15,
                                 y: height-imageSize-15,
                                 width: imageSize,
                                 height:imageSize)
        imageView.layer.cornerRadius = imageSize/2

        typeOfLink.sizeToFit()
        typeOfLink.frame = CGRect(
            x: imageView.right+10,
            y: height-imageSize,
            width: typeOfLink.width,
            height: typeOfLink.height
        )
        
        requestButtom.frame = CGRect(x: width-5-requestButtom.width,
                                     y: height-imageSize,
                                     width: 100,
                                     height: 25)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ConfigureUI
    func configure(with viewModel: PostOfFeedCollectionViewModel) {
        
        // add index parameter
        typeOfLink.text = viewModel.linkType

        guard let image = viewModel.mainImage?[0] else {
            return
        }
        
        DispatchQueue.main.async {
            self.imageView.sd_setImage(with: viewModel.linkTypeImage, completed: nil)
            self.backgroundImageView.sd_setImage(with: URL(string: image), completed: nil)
        }
            
    }

    
   
    
}


