//
//  RegisterViewController.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 19/01/22.
//

import UIKit
import AuthenticationServices
import Firebase
import GoogleSignIn

class RegisterViewController: UIViewController, LoginAuthenticator {
    
    weak var delegate: ASAuthorizationControllerDelegate?
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var minimumHintLabel: UILabel!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var appleLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var forgetPasswordLabel: UILabel! {
        didSet {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressForgetPassword))
            forgetPasswordLabel.isUserInteractionEnabled = true
            forgetPasswordLabel.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonTitle()
        
        delegate = self
        self.title = L("landing_login_button")

        descriptionLabel.text = L("register_byline")
        minimumHintLabel.text = L("register_password_min_hint")
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.keyboardType = .emailAddress
        
        let attributedString = NSAttributedString(string: L("register_login_forget_password_title"),
                                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                                               NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                               NSAttributedString.Key.foregroundColor: UIColor.black])
        forgetPasswordLabel.attributedText = attributedString
    }
    
    private func setButtonTitle() {
        let prefix = L("signin_button_title")
        let appleButtonTitle = "    " + prefix + " " + L("apple_button_title")
        let googleButtonTitle = "    " + prefix + " " +  L("google_button_title")
        let createAccountButtonTitle = L("landing_login_button")
        
        appleLoginButton.setTitle(appleButtonTitle, for: .normal)
        googleLoginButton.setTitle(googleButtonTitle, for: .normal)
        createAccountButton.setTitle(createAccountButtonTitle, for: .normal)
    }
    
    @IBAction func handleAppleIdRequest(_ sender: Any) {
        sendAppleSignInRequest()
    }
    
    @IBAction func handleGoogleRequest(_ sender: Any) {
        startLoading()
        sendGoogleSignInRequest { [weak self] _, error in
            self?.stopLoading()
            if let error = error {
                self?.handleMultiFactorAuthentication(error: error)
            }
            self?.fetchUserProfile()
        }
    }
    
    @IBAction func createAccountButtonClicked(_ sender: Any) {
        self.startLoading()
        signInGoogleUser(
            with: emailTextField.text!,
            password: passwordTextField.text!) { [weak self] result, error in
                guard error == nil else {
                    //There is no user record corresponding to this identifier. The user may have been deleted
                    //ERROR_USER_NOT_FOUND
                    if error?.code == 17011 {
                        self?.createUser()
                    } else {
                        self?.stopLoading()
                        self?.showError(error ?? NSError())
                    }
                    return
                }
                self?.fetchUserProfile()
            }
    }
    
    @IBAction func showPassword(_ sender: Any) {
        if (passwordTextField.isSecureTextEntry == true) {
            passwordTextField.isSecureTextEntry = false
        } else {
            passwordTextField.isSecureTextEntry = true
        }
    }
    @objc func didPressForgetPassword() {
        let viewController = ForgotPasswordViewController.instantiateFrom(storyboard: .register)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .black
        navigationItem.backBarButtonItem?.title = " "
        show(viewController, sender: self)
    }
    private func fetchUserProfile() {
//        ApiProvider
//            .default
//            .request(Api.getUser)
//            .response(UserProfile.self) { [weak self] response in
//                self?.stopLoading()
//                if let value = response.value {
//                    self?.handle(response: value)
//                } else if let error = response.error {
//                    self?.showError(error)
//                }
//            }
        handle()
    }
    
    //MARK: - Navigation
    private func handle() {
        DispatchQueue.main.async { [unowned self] in
            //Show dashboard after onboarding
            let viewController = DashboardViewController.instantiateFrom(storyboard: .dashboard)
            let navigationController = CustomNavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
//            viewController.user = response
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    //MARK: -
    private func createUser() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        self.createGoogleUser(with: email, password: password) { [weak self] result, error in
            self?.stopLoading()
            if error == nil {
                self?.fetchUserProfile()
            }
        }
    }
    @IBAction func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
                createAccountButton.isEnabled = false
                return
            }
        createAccountButton.isEnabled = true
    }
    //MARK: - Show Error
    func showError(_ error: Error) {
        DispatchQueue.main.async { [unowned self] in
            self.displayError(error)
        }
    }
    //MARK: - State
    func startLoading() {
        loadingView.startAnimating()
        createAccountButton.isHidden = true
    }
    func stopLoading() {
        loadingView.stopAnimating()
        createAccountButton.isHidden = false
    }
}

extension RegisterViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
              guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
              }
              guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
              }
            startLoading()
            sendAppleSignInRequest(with: idTokenString) { [weak self] (result, error) in
                if let error = error {
                    self?.handleMultiFactorAuthentication(error: error)
                }
                self?.fetchUserProfile()
            }
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showError(error)
    }
}

//MARK: - UITextField Delegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
