//
//  SignInViewController.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import UIKit
import JGProgressHUD

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    

    // Subviews
    private let spinner = JGProgressHUD(style: .dark)
    private let mainTitle: UILabel = {
        let title = UILabel()
        title.text = "Log In"
        title.textColor = .systemPurple
        title.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        return title
    }()

    private let subTitle: UILabel = {
        let title = UILabel()
        title.text = "Please sign in to continue"
        title.textColor = .white
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
    
    private let emailFieldImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "envelope")
        iv.tintColor = .black
        return iv
    }()

    private let passwordField: LinkTextField = {
        let field = LinkTextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        return field
    }()
    
    private let passwordFieldImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "lock")
        iv.tintColor = .black
        return iv
    }()


    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemPurple
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    
    private let forgotButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(.systemPurple, for: .normal)
        return button
    }()
    
    private let titleForNoAccount: UILabel = {
        let title = UILabel()
        title.text = "Don't have an account?"
        title.textColor = .white
        title.alpha = 0.7
        title.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return title
    }()

    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemPurple, for: .normal)
        button.setTitle("Create Account", for: .normal)
        return button
    }()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .systemBackground
        addSubviews()
        emailField.delegate = self
        passwordField.delegate = self

        addButtonActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        

        
        mainTitle.frame = CGRect(x: 25, y: view.height/4, width: view.width-50, height: 60)
        subTitle.frame = CGRect(x: 25, y: mainTitle.bottom+10, width: view.width, height: 50)
        emailFieldImage.frame = CGRect(x: 25, y: subTitle.bottom+20, width: 50, height: 50)
        emailField.frame = CGRect(x: emailFieldImage.right+2, y: subTitle.bottom+20, width: view.width-emailFieldImage.width-50, height: 50)
        passwordFieldImage.frame = CGRect(x: 25, y: emailFieldImage.bottom+10, width: 50, height: 50)
        passwordField.frame = CGRect(x: passwordFieldImage.right+2, y: emailField.bottom+10, width: view.width-passwordFieldImage.width-50, height: 50)
        signInButton.frame = CGRect(x: (view.width-signInButton.width-200)/2, y: passwordField.bottom+20, width: 200, height: 70)
        forgotButton.frame = CGRect(x: (view.width-forgotButton.width-300)/2, y: signInButton.bottom+10, width: 300, height: 20)
        titleForNoAccount.frame = CGRect(x:(view.width-titleForNoAccount.width-220)/2, y: forgotButton.bottom+50, width: 250, height: 50)
        createAccountButton.frame = CGRect(x: (view.width-createAccountButton.width-200)/2, y: titleForNoAccount.bottom, width: 200, height: 20)
      
    }

    private func addSubviews() {
        view.addSubview(mainTitle)
        view.addSubview(subTitle)
        view.addSubview(emailFieldImage)
        view.addSubview(passwordFieldImage)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(forgotButton)
        view.addSubview(titleForNoAccount)
        view.addSubview(createAccountButton)

    }

    private func addButtonActions() {
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
    
    }

    // MARK: - Actions

    @objc func didTapSignIn() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()

        guard let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            return
        }

        
        spinner.show(in: view)
        // Sign in with authManager
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.spinner.dismiss()
                
//                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
//                DatabaseManager.shared.getDataFor(path: safeEmail, completion: { [weak self] result in
//                    switch result {
//                    case .success(let data):
//                        guard let userData = data as? [String:Any],
//                              let username = userData["username"] as? String else {
//                            return
//                        }
//
//                        UserDefaults.standard.setValue(username, forKey: "username")
//                    case .failure(let error):
//                        print("Failed to read data with error: \(error)")
//                    }
//
//                })
                
                switch result {
                case .success:
                    HapticManager.shared.vibrate(for: .success)
                    let vc = TabBarViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(
                        vc,
                        animated: true,
                        completion: nil
                    )

                case .failure(let error):
                    HapticManager.shared.vibrate(for: .error)
                    print(error)
                }
            }
        }
    }

    @objc func didTapCreateAccount() {
        let vc = SignUpViewController()
        vc.completion = { [weak self] in
            DispatchQueue.main.async {
                let tabVC = TabBarViewController()
                tabVC.modalPresentationStyle = .fullScreen
                self?.present(tabVC, animated: true)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }


    // MARK: Field Delegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapSignIn()
        }
        return true
    }
}

