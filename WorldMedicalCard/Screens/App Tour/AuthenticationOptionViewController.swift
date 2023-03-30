//
//  AuthenticationOptionViewController.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 17/01/22.
//

import UIKit

class AuthenticationOptionViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override var navigationItemBackButtonTextIsHidden: Bool { return true }

    //MARK: - Setup View
    
    func setupView() {
        loginButton.setTitle(L("landing_login_button"), for: .normal)
        titleLabel.text = L("world_medical_card_r")
        descriptionLabel.text = L("your_personal_medical_record_n_always_available")
        registerButton.setTitle(L("landing_register_button"), for: .normal)
    }
    
    @IBAction func loginButtonClicked() {
        let viewController = TermsAndConditionsViewController.instantiateFrom(storyboard: .appTour)
        show(viewController, sender: self)
    }
    
    @IBAction func registerButtonClicked() {
        let viewController = TermsAndConditionsViewController.instantiateFrom(storyboard: .appTour)
        show(viewController, sender: self)
    }
}
