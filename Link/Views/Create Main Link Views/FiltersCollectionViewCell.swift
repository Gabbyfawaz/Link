//
//  FiltersCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/08/20.
//

import UIKit

class FiltersCollectionViewCell: UICollectionViewCell {
    static let identifier = "FiltersCollectionViewCell"

    private var filters = ["Chrome", "Fade", "Mono", "Instant", "Noir", "Process", "Tonal", "Transfer"]
    
    
    
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.tintColor = .label
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
//        contentView.insertSubview(label , at: 1)
        
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
//        label.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
//        label.text = nil
    }

//    func configure(with image: UIImage?) {
//        imageView.image = image?.addFilter(filter: .Mono)
//
//    }
    
    func configure(with url: URL?) {
        imageView.sd_setImage(with: url, completed: nil)
        
    }
    
    func configure(stringURL: String) {
        imageView.sd_setImage(with: URL(string: stringURL), completed: nil)
        
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
        
    }
    
    func configure(with string: String, image: UIImage?) {
        
        let image = image?.fixOrientation()
//        let text = label.text
        switch string {
        case "Original":
            imageView.image = image
        case "Chrome":
            imageView.image = image?.addFilter(filter: .Chrome)
        case "Fade":
            imageView.image = image?.addFilter(filter: .Fade)
        case "Mono":
            imageView.image = image?.addFilter(filter: .Mono)
        case "Instant":
            imageView.image = image?.addFilter(filter: .Instant)
        case "Noir":
            imageView.image = image?.addFilter(filter: .Noir)
        case "Process":
            imageView.image = image?.addFilter(filter: .Process)
        case "Tonal":
            imageView.image = image?.addFilter(filter: .Tonal)
        case "Transfer":
            imageView.image = image?.addFilter(filter: .Transfer)

        default:
            break
        }
       
    }
    
   
    func configure(with text: String) {
        label.text = text
    }
    
//    func configureReturn(with text: String) -> String {
//
//        guard let string = label.text else {
//            return ""
//        }
//
//        return string
//    }

   
}
