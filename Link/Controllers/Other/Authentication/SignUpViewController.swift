//
//  SignUpViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//
import SafariServices
import UIKit
//import JGProgressHUD
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Subviews


//    private let spinner = JGProgressHUD(style: .dark)
    private let mainTitle: UILabel = {
        let title = UILabel()
        title.text = "Create"
        title.textColor = .label
        title.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        return title
    }()
    private let mainTitle2: UILabel = {
        let title = UILabel()
        title.text = "Account"
        title.textColor = .label
        title.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        return title
    }()


    private let subTitle: UILabel = {
        let title = UILabel()
        title.text = "Please fill the input below here"
        title.textColor = .label
        title.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return title
    }()
    
    private let emailField: LinkTextField = {
        let field = LinkTextField()
        field.placeholder = "Email Address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .no
        return field
    }()
    
//    private let emailFieldImage: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(systemName: "envelope")
//        iv.tintColor = .label
//        return iv
//    }()
    
    private let usernameField: LinkTextField = {
        let field = LinkTextField()
        field.placeholder = "Username"
        field.returnKeyType = .next
        field.autocorrectionType = .no
        return field
    }()
    
//    private let usernameImage: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(systemName: "person.fill")
//        iv.tintColor = .label
//        return iv
//    }()
    
    private let passwordField: LinkTextField = {
        let field = LinkTextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        return field
    }()
    
//    private let passwordFieldImage: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(systemName: "lock")
//        iv.tintColor = .label
//        return iv
//    }()


    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    

    
    private let alreadyHaveAccount: UILabel = {
        let title = UILabel()
        title.text = "Already have an account?"
        title.textColor = .label
        title.alpha = 0.7
        title.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return title
    }()

    private let backToLogInButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Log in", for: .normal)
        return button
    }()


    public var completion: (() -> Void)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .systemBackground
        addSubviews()
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        addButtonActions()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
           view.addGestureRecognizer(tap)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainTitle.frame = CGRect(x: 25, y: view.height/8, width: view.width-50, height: 50)
        mainTitle2.frame = CGRect(x: 25, y: mainTitle.bottom+2, width: view.width-50, height: 50)
        subTitle.frame = CGRect(x: 25, y: mainTitle2.bottom+50, width: view.width, height: 50)
//        usernameImage.frame = CGRect(x: 25, y: subTitle.bottom+10, width: 50, height: 50)
        usernameField.frame = CGRect(x: 30, y: subTitle.bottom+10, width: view.width-60, height: 50)
//        emailFieldImage.frame = CGRect(x: 25, y: usernameField.bottom+10, width: 50, height: 50)
        emailField.frame = CGRect(x: 30, y: usernameField.bottom+10, width: view.width-60, height: 50)
//        passwordFieldImage.frame = CGRect(x: 25, y: emailFieldImage.bottom+10, width: 50, height: 50)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+10, width: view.width-60, height: 50)
        signUpButton.frame = CGRect(x: (view.width-signUpButton.width-200)/2, y: passwordField.bottom+40, width: 200, height: 70)
        alreadyHaveAccount.frame = CGRect(x: (view.width-alreadyHaveAccount.width-250)/2, y: signUpButton.bottom+50, width: 300, height: 50)
        backToLogInButton.frame = CGRect(x: (view.width-backToLogInButton.width-200)/2, y: alreadyHaveAccount.bottom, width: 200, height: 20)
    }

    private func addSubviews() {
        view.addSubview(mainTitle)
        view.addSubview(subTitle)
//        view.addSubview(emailFieldImage)
//        view.addSubview(passwordFieldImage)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        view.addSubview(backToLogInButton)
        view.addSubview(alreadyHaveAccount)
//        view.addSubview(usernameImage)
        view.addSubview(usernameField)
        view.addSubview(mainTitle2)
    }


    private func addButtonActions() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        backToLogInButton.addTarget(self, action: #selector(didTapBackToLogIn), for: .touchUpInside)
    }
    

    // MARK: - Actions

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    

    @objc func didTapSignUp() {
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()

        guard let email = emailField.text,
              let password = passwordField.text,
              let username = usernameField.text,
              !username.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            self.alertUserLoginError()
            return
        }

//        spinner.show(in: view)

        DatabaseManager.shared.userExists(with: email) { [weak self] exist in

//            guard let strongSelf = self else {
//                 return
//             }

//            strongSelf.spinner.dismiss()

            guard !exist else  {
                // User already exists
                self?.alertUserLoginError(message: "User already Exists")
                return
            }
            AuthManager.shared.signUp(
                email: email,
                username: username,
                password: password
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        HapticManager.shared.vibrate(for: .success)
                        UserDefaults.standard.setValue(user.email, forKey: "email")
                        UserDefaults.standard.setValue(user.username, forKey: "username")

                        let vc = TabBarViewController()
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(
                            vc,
                            animated: true,
                            completion: nil
                        )
                        self?.completion?()
                    case .failure(let error):
                        HapticManager.shared.vibrate(for: .error)
                        print("\n\nSign Up Error: \(error)")
                    }
                }


                DatabaseManager.shared.insertUser(
                    with: ChatAppUser(
                        username: username,
                        emailAddress: email), completion: {
                            success in
                            if success {
                                // Sign up with authManager
                            }
                        })
            }
        }
        
    
        
    }

    func alertUserLoginError(message: String = "Please enter all information to create a new account.") {
                let alert = UIAlertController(title: "Whoops", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
                
            }

    @objc func didTapBackToLogIn() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: Field Delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapSignUp()
        }
        return true
    }


}
