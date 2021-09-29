//
//  CommentBarView.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit

protocol CommentBarViewDelegate: AnyObject {
    func commentBarViewDidTapDone(_ commentBarView: CommentBarViewController, withText text: String)
}

final class CommentBarViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: CommentBarViewDelegate?
    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?
    
    
    private let noCommentsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Comments"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.text = "Comments"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private var commentBarView = UIView()

    private var commentModel: [Comment]
    public let button: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()

    private let field: LinkTextField = {
        let field = LinkTextField()
        field.placeholder = "Comment"
        field.backgroundColor = .systemBackground
        field.layer.cornerRadius = 8
        return field
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(CommentCollectionViewCell.self, forCellReuseIdentifier: CommentCollectionViewCell.identifier)
        table.isHidden = true
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.addSubview(commentLabel)
        view.addSubview(commentBarView)
        view.addSubview(noCommentsLabel)
        view.addSubview(field)
        view.addSubview(button)
        commentBarView.addSubview(field)
        commentBarView.addSubview(button)
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        field.delegate = self
        button.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        
        if commentModel.count == 0 {
            noCommentsLabel.isHidden = false
        } else {
            tableView.isHidden = false
        }
        
        
        
        observeKeyboardChange()
        view.backgroundColor = .tertiarySystemBackground

    }
    
    
    init(commentModel: [Comment]) {
        self.commentModel = commentModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    @objc func didTapComment() {
        guard let text = field.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        delegate?.commentBarViewDidTapDone(self, withText: text)
        field.resignFirstResponder()
        field.text = nil
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.sizeToFit()
        commentLabel.frame = CGRect(x: 0, y: 0, width: view.width, height: 60)
        tableView.frame = CGRect(x: 0, y: commentLabel.bottom+10, width: view.width, height: view.height-100-commentLabel.height)
        
        noCommentsLabel.sizeToFit()
        noCommentsLabel.frame = CGRect(x: 0, y: commentLabel.bottom+10, width: view.width, height: view.height-100-commentLabel.height)
        
        commentBarView.frame = CGRect(x: 0, y: tableView.bottom, width: view.height, height: 50)
        
        button.frame = CGRect(x: view.width-button.width-5, y: (commentBarView.height-button.height)/2,
                              width: button.width, height: button.height)
        field.frame = CGRect(x: 10, y: (commentBarView.height-50)/2, width: view.width-button.width-20, height: 50)
    }
    
    private func observeKeyboardChange() {
        observer = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
                return
            }
            UIView.animate(withDuration: 0.2) {
                self.commentBarView.frame = CGRect(
                    x: 0,
                    y: self.view.height-60-height,
                    width: self.view.width,
                    height: 70
                )
            }
        }

        hideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            UIView.animate(withDuration: 0.2) {
                self.commentBarView.frame = CGRect(
                    x: 0,
                    y: self.view.height-self.view.safeAreaInsets.bottom-70,
                    width: self.view.width,
                    height: 70
                )
            }
        }
    }

 

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        didTapComment()
        return true
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = commentModel[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCollectionViewCell.identifier, for: indexPath) as? CommentCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentModel.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

