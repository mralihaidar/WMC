//
//  SubcriptionInviteViewController.swift
//  WorldMedicalCard
//
//  Created by Apphuset on 03/06/2022.
//

import UIKit

final class SubscriptionInviteViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    var subscriptionId: Int! // injection

    var invitedHandler = {}

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.placeholder = L("subscription_add_member_placeholder_email")
        navigationItem.rightBarButtonItem?.title = L("subscription_add_member_action_add")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.emailTextField.becomeFirstResponder()
        }
    }

    @IBAction func cancelTapped() {
        dismiss(animated: true)
    }

    @IBAction func addTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            return
        }

        invite(email: email)
    }

    private func invite(email: String) {
        toggleLoading(true)

        ApiProvider.default.request(Api
            .inviteSubscriptionMember(subscriptionId: subscriptionId, email: email))
            .response { [weak self] response in
                self?.toggleLoading(false)

                if let error = response.error {
                    self?.displayError(error)
                } else {
                    self?.succeeded()
                }
            }
    }


    private func toggleLoading(_ isLoading: Bool) {
        view.isUserInteractionEnabled = !isLoading

        if isLoading {
            let loadingView = UIActivityIndicatorView()
            loadingView.startAnimating()
            navigationItem.rightBarButtonItem?.customView = loadingView
            view.endEditing(true)
        } else {
            navigationItem.rightBarButtonItem?.customView = nil
        }
    }

    private func showError(error: Error) {
        displayError(error)
    }

    private func succeeded() {
        invitedHandler()
        
        let alert = UIAlertController(
            title: L("subscription_add_member_alert_invite_title"),
            message: L("subscription_add_member_alert_invite_message"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L("subscription_add_member_alert_invite_ok"), style: .default, handler: { _ in
            self.dismiss(animated: true)
        }))

        present(alert, animated: true)
    }
}
