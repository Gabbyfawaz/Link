//
//  CaptionCollectionViewCell.swift
//  
//
//  Created by Gabriella Fawaz on 2021/08/25.
//


protocol CaptionTableViewDelegate: AnyObject{
    func captionTableViewEventInfo(_ view: CaptionTableView, eventInfo: String)
}
import UIKit

class CaptionTableView: UIView {
    
    weak var delegate: CaptionTableViewDelegate?
    
    private var captionTextField: UITextField = {
        let textField = UITextField()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        textField.leftViewMode = .always
        textField.backgroundColor = .systemBackground
        textField.placeholder = "Caption"
        textField.font = .systemFont(ofSize: 21, weight: .light)
        return textField
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Event Information"
        label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        label.textAlignment = .left
        label.textColor = .white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.backgroundColor = .black
        return label
    }()
    
    private let infoTextField: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = .secondarySystemBackground
        textField.textColor = .black
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1
        textField.font = .systemFont(ofSize: 21, weight: .regular)
//        textField.layer.cornerRadius = 8
        return textField
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    
        addSubview(captionTextField)
        addSubview(infoLabel)
        addSubview(infoTextField)
        addSubview(lineView)
        
        delegate?.captionTableViewEventInfo(self, eventInfo: infoTextField.text)
      
    }
    
    required init?(coder: NSCoder) {
        fatalError()
        }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        captionTextField.frame = CGRect(x: 15,
                                        y: 40,
                                        width: 400,
                                        height: 50)
        lineView.frame = CGRect(x: 15,
                                y: captionTextField.bottom,
                                width: 400,
                                height: 2)
        infoLabel.frame = CGRect(x:15,
                                 y: captionTextField.bottom+10,
                                 width: 430,
                                 height: 40)
        infoTextField.frame = CGRect(x: 15,
                                     y: infoLabel.bottom+10,
                                     width: 400,
                                     height: 200)

    }

    
    
    func configure(caption: String) {
        
        
        
    }
}
