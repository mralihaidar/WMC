//
//  TermsAndConditionsViewController.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 19/01/22.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {
    
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textView: UITextView!

    var isFromDashboard = false

    override var navigationItemBackButtonTextIsHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = L("terms_and_conditions_title")
        textView.text = L("terms_text")
        termsButton.setTitle(L("i_accept_the_terms_and_conditions"), for: .normal)
        termsButton.isHidden = isFromDashboard //hide accept terms button when terms open from dashboard
        if isFromDashboard {
            //Hide bottom view when opening terms from dashboard
            bottomViewHeightConstraint.constant = 0
        }
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func acceptButtonClicked(_ sender: Any) {
        let viewController = RegisterViewController.instantiateFrom(storyboard: .register)
        show(viewController, sender: self)
    }
}
