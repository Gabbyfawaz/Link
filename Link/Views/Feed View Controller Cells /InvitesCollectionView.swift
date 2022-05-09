//
//  InvitesCollectionView.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/31.
//

import UIKit


protocol InvitesCollectionViewDelegate: AnyObject {
    func invitesCollectionViewDelegateDidTapRequest(_ view: InvitesCollectionView, linkId: String, username: String, isRequesting: Bool)
    func invitesCollectionViewDelegateDidTapAccept(_ view: InvitesCollectionView, linkId: String, username: String, isAccepted: Bool)

}
class InvitesCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    
    // MARK: PROPERTIES
    
    private var observer: NSObjectProtocol?
    private var pendingUsers = [SearchUser]()
    private var confirmedUsers = [SearchUser]()
    private var usersArray = [SearchUser]()
    private var isRequested = false
    private var isAccepted = false
    private var linkId: String?
    private var username: String?
    private var index = 0
    private var actionButton = NameOfLinkCollectionCellViewActions.request(isRequested: false)
    weak var delegate: InvitesCollectionViewDelegate?
    
    private let requestButton: LinkRequestButton = {
        let button = LinkRequestButton()
        button.isHidden = true
        return button
    }()
    
    private let acceptButton: LinkAcceptButton = {
        let button = LinkAcceptButton()
        button.isHidden = true
        return button
    }()

    private var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["20 Pending", "10 Confirmed"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .systemBackground
        sc.backgroundColor = .systemBackground
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .tertiarySystemBackground
        return sc
    }()
    
    
//    private let commentsLabel: UILabel = {
//        let label = UILabel()
//        label.text = "View Comments"
//        label.textAlignment = .left
//        label.textColor = .tertiaryLabel
//        label.font = .systemFont(ofSize: 15, weight: .light)
//        label.layer.masksToBounds = true
//        label.layer.cornerRadius = 8
//        return label
//    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Event Date"
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        return label
    }()
    
    private let actualDate: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
    
        return label
    }()
    
    private var dateVerticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.layer.masksToBounds = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 1
        stack.layer.masksToBounds = true
        stack.layer.cornerRadius = 8
        stack.backgroundColor = .systemBackground
        return stack
    }()
    


    private var peopleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 100, height: 100)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AddUsersToLinkCollectionViewCell.self,
                                forCellWithReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier)
        return collectionView
    }()
    
    
    


    //MARK: LIFECYCLE

    override init(frame: CGRect) {
        super.init(frame: frame)
//        clipsToBounds = true
        backgroundColor = .systemBackground
        addSubview(segmentedControl)
        addSubview(peopleCollectionView)
        addSubview(requestButton)
        addSubview(acceptButton)
        
        peopleCollectionView.delegate = self
        peopleCollectionView.dataSource = self
    
        addSubview(dateVerticalStackView)
        dateVerticalStackView.addArrangedSubview(dateLabel)
        dateVerticalStackView.addArrangedSubview(actualDate)
        segmentedControl.addTarget(self, action: #selector(handleSegmentedControlChange), for: .valueChanged)
//        segmentedControl.addTarget(self, action: Selector(("tapSegment:")), for: .touchDown)
        requestButton.addTarget(self, action: #selector(didTapRequest), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(didTapAccept), for: .touchUpInside)
        
//        observer = NotificationCenter.default.addObserver(
//            forName: .didUpdateAcceptButton,
//            object: nil,
//            queue: .main
//        ) { [weak self] notif in
//            guard let isAccepted = notif.userInfo?.first?.value as? Bool else {
//                return
//            }
//            self?.isAccepted = isAccepted
//            self?.actionButton = .accept(isAccepted: isAccepted)
//
//            guard let action = self?.actionButton else {
//                return
//            }
//            self?.configureButton(action: action)
//        }
       
    }

    required init?(coder: NSCoder) {
        fatalError()
    }


    //MARK: LAYOUT SUBVIEWS


    override func layoutSubviews() {
        super.layoutSubviews()

//        peopleInvitedButton.frame = CGRect(x: 15, y: 20, width: 50, height: 50)
//        peopleCollectionView.layer.cornerRadius = 20
        let scWidth = (width)/2
        segmentedControl.setWidth(scWidth, forSegmentAt: 0)
        segmentedControl.setWidth(scWidth, forSegmentAt: 1)
        segmentedControl.frame = CGRect(x: 0,
                                 y: 5,
                                        width: segmentedControl.width,
                                        height: segmentedControl.height)
        peopleCollectionView.frame = CGRect(x: 10, y: segmentedControl.bottom+20, width: width-20, height: 120)
//        verticalStackView.frame = CGRect(x: 15,
//                                         y: 60,
//                                         width: 50,
//                                         height: 100)
        requestButton.frame = CGRect(x: 10,
                                     y: peopleCollectionView.bottom+20,
                                    width: 120,
                                    height: 30)
        acceptButton.frame = CGRect(x: 10,
                                     y: peopleCollectionView.bottom+20,
                                    width: 120,
                                    height: 30)
        
        dateVerticalStackView.frame = CGRect(x: width-15-dateVerticalStackView.width,
                                             y: peopleCollectionView.bottom+20,
                                             width: 130,
                                             height: 30)
        
       
    }

    

    //MARK: ACTIONS FOR BUTTONS
    

    @objc func handleSegmentedControlChange() {
        // change the input of users in viewModel
        
        if segmentedControl.selectedSegmentIndex == 0 {
            usersArray = pendingUsers
            peopleCollectionView.reloadData()
          print("This is the pending section")
        } else if segmentedControl.selectedSegmentIndex == 1 {
            usersArray = confirmedUsers
            peopleCollectionView.reloadData()
            print("This is the confirmed section")
        }
        
    }
    

    
    private func configureButton(action: NameOfLinkCollectionCellViewActions) {
        
        
            
            switch action {
            case .request(let isRequested):
                requestButton.isHidden = false
                self.isRequested = isRequested
                requestButton.configure(for: isRequested ? .requesting : .request)
            case .accept(let isAccepted):
                acceptButton.isHidden = false
                self.isAccepted = isAccepted
                acceptButton.configure(for: isAccepted ? .accepted : .accept)
            }
    }
    
//    func configureButtonViewReload() {
//
//        guard let username = username, let linkId = linkId else {
//            return
//        }
//
//
//        DatabaseManager.shared.isRequestEvent(targetUsername: username, linkId: linkId) { isRequested in
//
//            self.actionButton = .request(isRequested: isRequested)
////            let button = .res
//            self.configureButton(action: self.actionButton)
//        }
//    }
    
    @objc private func didTapAccept() {

        print("the request button has been tapped")
        
        guard let linkId = self.linkId,
              let username = self.username
        else {
           return
        }
        delegate?.invitesCollectionViewDelegateDidTapAccept(self, linkId: linkId, username: username, isAccepted: isAccepted)
        isAccepted = !isAccepted
        acceptButton.configure(for: isAccepted ? .accepted : .accept)
      
    }
    
    @objc private func didTapRequest() {
        print("the request button has been tapped")
        guard let linkId = self.linkId,
              let username = self.username
        else {
           return
        }
        delegate?.invitesCollectionViewDelegateDidTapRequest(self, linkId: linkId, username: username,  isRequesting: isRequested)
        isRequested = !isRequested
        requestButton.configure(for: isRequested ? .requesting : .request)
        
        
      
    }
    
    
    // MARK: CONFIGUREUI
        
        func configure(with viewModel: PostOfFeedCollectionViewModel) {
            self.pendingUsers = viewModel.pendingUsers
            self.confirmedUsers = viewModel.confirmedUsers
            self.linkId = viewModel.linkId
            self.username = viewModel.username
            configureButton(action: viewModel.actionButton)
            self.usersArray = pendingUsers
            let pendingTitle = "\(pendingUsers.count) Pending"
            let confirmedTitle = "\(confirmedUsers.count) Confirmed"
            let date = Date(timeIntervalSince1970: viewModel.date)
            let dataString = DateFormatter.formatter.string(from: date)
            actualDate.text = dataString
            segmentedControl.setTitle(pendingTitle, forSegmentAt: 0)
            segmentedControl.setTitle(confirmedTitle, forSegmentAt: 1)
            
            
        }
    
    //MARK: - CollectionViewDataSource/Delegate

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of users selected\(pendingUsers.count)")
        return usersArray.count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = usersArray[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AddUsersToLinkCollectionViewCell.identifier,
                for: indexPath
        ) as? AddUsersToLinkCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: model)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: peopleCollectionView.height, height: peopleCollectionView.height)
    }

}


