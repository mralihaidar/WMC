//
//  ForgotPasswordViewController.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 8/22/22.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    override var navigationItemBackButtonTextIsHidden: Bool { return true }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = L("forgot_password_screen_title")
        descriptionLabel.text = L("forgot_password_screen_description")
        emailTextField.delegate = self
        emailTextField.keyboardType = .emailAddress
    }
    
    @IBAction func didPressResetPassword(_ sender: UIButton) {
        guard let text = emailTextField.text, !text.isEmpty else {
            return
        }
        startLoading()
        resetPasswordButton.isEnabled = true
        Auth.auth().sendPasswordReset(withEmail: text) { [weak self] error in
            self?.stopLoading()
            if error == nil {
                self?.alert(title: nil, message: L("forgot_password_alert_message"), ok: nil)
            } else {
                self?.alert(title: nil, message: L("error_message"), ok: nil)
            }
        }
    }
    //MARK: - State
    func startLoading() {
        loadingView.startAnimating()
        resetPasswordButton.isHidden = true
    }
    func stopLoading() {
        loadingView.stopAnimating()
        resetPasswordButton.isHidden = false
    }
}
//MARK: - UITextField Delegate
extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
