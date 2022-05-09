//
//  PostLogisticCollectionViewCell.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//
import UIKit

protocol PostLogisticCollectionViewCellDelegate: AnyObject {
    func postLogisticCollectionViewCellDidTapLogistics(_ cell: PostLogisticCollectionViewCell)
}

final class PostLogisticCollectionViewCell: UICollectionViewCell {
     static let identifier = "PostLogisticCollectionViewCell"
    

    weak var delegate: PostLogisticCollectionViewCellDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
//    private let logisticButton: UIButton = {
//            let button = UIButton()
//            button.tintColor = .label
//        button.setTitle("Logistics", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//            return button
//    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
//        contentView.addSubview(logisticButton)
        
//        logisticButton.addTarget(self, action: #selector(didTapGesture), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Actions
    
    @objc private func didTapGesture() {
        delegate?.postLogisticCollectionViewCellDidTapLogistics(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.sizeToFit()
        label.frame = CGRect(x: 15, y: 10, width: label.width, height: label.height)
//        logisticButton.frame = CGRect(x: contentView.width-100-10, y: 8, width: 100, height: contentView.height-16)
//        logisticButton.layer.cornerRadius = 8
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    func configure(with viewModel: PostLogisticCollectionViewCellViewModel) {
        
        let stringDate = DateFormatter.formatter.string(from: Date(timeIntervalSince1970: viewModel.date))
        
        label.text = stringDate

}
    


}

