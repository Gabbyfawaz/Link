//
//  QuickLinkSticker.swift
//  Link
//
//  Created by Gabriella Fawaz on 01/03/2022.
//

import UIKit

protocol QuickLinkStickerDelegate: AnyObject {
    func quickLinkStickerDelegateDidTapCancel(_ view: QuickLinkSticker)
    func quickLinkStickerDelegateDidTapClock(_ view: QuickLinkSticker)
    func quickLinkStickerDelegateDidTapLocation(_ view: QuickLinkSticker)
    func quickLinkStickerDelegateDidTapPeople(_ view: QuickLinkSticker)
    func quickLinkStickerDelegateDidButton(_ view: QuickLinkSticker, isJoined: Bool)
}


class QuickLinkSticker: UIView {
    
    
    weak var delegate: QuickLinkStickerDelegate?

    private var isJoined = false
    public let textfield: UITextView = {
        let tf = UITextView()
        tf.text = "Link Title"
        tf.textAlignment = .left
        tf.textColor = .black
        tf.textAlignment = .center
//        tf.leftViewMode = true
//        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
//        tf.leftViewMode = .always
        tf.backgroundColor = .white
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        tf.layer.cornerRadius = 10
        tf.clipsToBounds = true
//        tf.translatesAutoresizingMaskIntoConstraints = true
//        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return tf
    }()
    
    private let locationTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .left
        title.textColor = .label
        title.font = .systemFont(ofSize: 16, weight: .medium)
        return title
    }()
    
    
    private var horizonatlstackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.backgroundColor = .black
        return stack
    }()
    private var  stackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.backgroundColor = .white
        return stack
    }()
    
    public let joinButton: UIButton = {
        let button = UIButton()
        button.setTitle("Join", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemYellow
      
        return button
    }()
    
    public let locationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    public let timeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "clock",withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    public let peopleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.2", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    var textHeightConstraint: NSLayoutConstraint?
    private let view = UIView()
    
//    private let cancelButton: UIButton = {
//       let button = UIButton()
//        button.setImage(UIImage(systemName: "multiply.circle"), for: .normal)
//        button.tintColor = .label
//        return button
//    }()
   
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 10
        addSubview(horizonatlstackView)
        horizonatlstackView.addArrangedSubview(locationButton)
        horizonatlstackView.addArrangedSubview(timeButton)
        horizonatlstackView.addArrangedSubview(peopleButton)
        addSubview(stackView)
        stackView.addArrangedSubview(textfield)
        addSubview(joinButton)
        textfield.delegate = self
        
            
        locationButton.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
        timeButton.addTarget(self, action: #selector(didTapTimeButton), for: .touchUpInside)
        peopleButton.addTarget(self, action: #selector(didTapPeopleButton), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(didTapJoinButton), for: .touchUpInside)
        self.textHeightConstraint = textfield.heightAnchor.constraint(equalToConstant: 80)
        self.textHeightConstraint?.isActive = true
        
        
//        adjustUITextViewHeight(arg: textfield)
        adjustTextViewHeight()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func layoutSubviews() {
        super.layoutSubviews()
    
        joinButton.frame = CGRect(x: 0,
                                  y: 0,
                             width: width,
                             height: 40)

//        textfield.frame = CGRect(x: 0,
//                                 y: joinButton.bottom,
//                             width: width,
//                             height: 70)

        horizonatlstackView.frame = CGRect(x: 0, y: joinButton.bottom, width: width, height: 30)
          
//        let height = textfield.nu
        stackView.frame = CGRect(x: 0, y: horizonatlstackView.bottom, width: width, height: 70)
    }
    
    func adjustTextViewHeight() {
        let fixedWidth = textfield.frame.size.width
        let newSize = textfield.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        self.textHeightConstraint?.constant = newSize.height
        self.view.layoutIfNeeded()
    }
    
    @objc func didCancelButton() {
        delegate?.quickLinkStickerDelegateDidTapCancel(self)
    }
    
    @objc func didTapLocation() {
        delegate?.quickLinkStickerDelegateDidTapLocation(self)
    }
    
    @objc func didTapTimeButton() {
        delegate?.quickLinkStickerDelegateDidTapClock(self)
    }
    
    @objc func didTapPeopleButton() {
        delegate?.quickLinkStickerDelegateDidTapPeople(self)
    }
    
    @objc func didTapJoinButton() {
        isJoined = !isJoined
        delegate?.quickLinkStickerDelegateDidButton(self, isJoined: isJoined)
        configureButton(with: isJoined)
    }
    
    func adjustUITextViewHeight(arg : UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
   
    private func configureButton(with isJoined: Bool) {
        
        if isJoined {
            
        }
    }
    
}


extension QuickLinkSticker: UITextViewDelegate {
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textfield.text == "Link Title" {
            textView.text = nil
            textView.becomeFirstResponder()
        }
       
        textView.becomeFirstResponder()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustTextViewHeight()
//        let height = textHeightConstraint
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
}
