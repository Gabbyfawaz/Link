//
//  PostInfoCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import SDWebImage

//protocol PostInfoCollectionViewCellDelegate: AnyObject {
////    func posterCollectionViewCellDidTapUsername(_ cell: PostInfoCollectionViewCell)
//}
  

final class PostInfoCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostInfoCollectionViewCell"
//    weak var delegate: PostInfoCollectionViewCellDelegate?
    


    //MARK: PROPERTIES
    private var index = 0
    private var labelInfo: String?
    public var label: UILabelPadding = {
        let label = UILabelPadding()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
//    private let usernameLabel: UILabel = {
//        let label = UILabel()
//        label.isUserInteractionEnabled = true
//        label.font = .systemFont(ofSize: 21, weight: .semibold)
//        return label
//    }()
//
//
    private let moreLabel: UILabel = {
        let label = UILabel()
        label.text = "...more"
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.font = label.font.italic
        label.tintColor = .secondarySystemBackground
        
        return label
    }()
    
    

    // MARK: LIFECYCLE

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
//        contentView.addSubview(usernameLabel)
        contentView.addSubview(moreLabel)
//        let tap = UITapGestureRecognizer(target: self,
//                                         action: #selector(didTapInfo))
//        usernameLabel.addGestureRecognizer(tap)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapMoreLabel))
        label.addGestureRecognizer(tap)
//
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
      

    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
//    @objc func didTapLabel(gesture: UITapGestureRecognizer) {
//        if  let text = label.text {
//            let more = "...more"
//            let less = "...less"
//            let moreRange = (text as NSString).range(of: more)
//            let lessRange = (text as NSString).range(of: less)
//            if gesture.didTapAttributedTextInLabel(label: label, inRange: moreRange) {
//                didTapMoreLabel(with: more)
//                print("Tapped terms")
//            } else if gesture.didTapAttributedTextInLabel(label: label, inRange: lessRange){
//                didTapMoreLabel(with: less)
//            } else {
//                print("Tapped none")
//            }
//    }
//        }
           

//
//    @objc func didTapInfo() {
//        delegate?.posterCollectionViewCellDidTapUsername(self)
//    }
//
    @objc func didTapMoreLabel() {
     
//        let array = ["...more", "...less"]
//             if word == "...more" {
//                 if var newLabel = self.labelInfo {
//                     newLabel = newLabel + array[1]
//                     self.label.text = newLabel
//                 }
//     //            moreLabel.text = array[index]
//                 label.numberOfLines = 0
//             } else if word == "...less" {
//                 if var newLabel = self.labelInfo {
//                     newLabel = newLabel + array[0]
//                     self.label.text = newLabel
//                 }
//                 label.numberOfLines = 2
//             }
     
         
         
        let array = ["...more", "...less"]
        index = index + 1

        if index == 0 {
            moreLabel.text = array[index]
            label.numberOfLines = 2
        } else if index == 1 {
            moreLabel.text = array[index]
            label.numberOfLines = 0
            index = index - 2
        }
         
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
//        moreLabel.sizeToFit()
//        moreLabel.frame = CGRect(x: label.right, y: label.right, width: moreLabel.width, height: moreLabel.height)
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
//        usernameLabel.text = nil
    }

 
//    func countLabelLines() -> Int {
//       // Call self.layoutIfNeeded() if your view is uses auto layout
//        let myText = self.label.text! as NSString
//        let attributes = [NSAttributedString.Key.font : self.label.font]
//
//       let labelSize = myText.boundingRect(with: CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
//        return Int(ceil(CGFloat(labelSize.height) / self.label.font.lineHeight))
//   }
//     func isTruncatedOrNot() -> Bool {
//
//         if (self.countLabelLines() > self.label.numberOfLines) {
//           return true
//       }
//       return false
//   }

    func configure(with viewModel: PostLinkExtraInfoCollectionCellViewModel) {
        self.labelInfo = viewModel.extraInfomation
        label.text = "\(viewModel.extraInfomation)"
//        print("Are you trancated: \(isTruncatedOrNot())")
    
//        label.addTrailing(with: viewModel.extraInfomation, moreText: "more", moreTextFont: UIFont(name: "Arial", size: 18) ?? UIFont() , moreTextColor: .tertiaryLabel)

//
    }
    
    
}



class UILabelPadding: UILabel {

    let padding = UIEdgeInsets(top: 2, left: 15, bottom: 2, right: 5)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
}
