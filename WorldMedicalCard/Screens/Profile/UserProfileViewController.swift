//
//  UserProfileViewController.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 30/01/22.
//

import UIKit
import FirebaseAuth

class UserProfileViewController: UIViewController {
    
    @IBOutlet var form: Form!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var organDonerTitleLabel: UILabel!
    @IBOutlet var organDonerDescriptionLabel: UILabel!
    @IBOutlet var postalAddressTitleLabel: UILabel!
    @IBOutlet var postalAddressDescriptionLabel: UILabel!
    @IBOutlet var insuranceSectionTitleLabel: UILabel!
    @IBOutlet var insuranceSectionDescriptionLabel: UILabel!
    @IBOutlet var emergencyContactTitleLabel: UILabel!
    @IBOutlet var emergencyContactDescriptionLabel: UILabel!
    @IBOutlet var otherInfoSectionTitleLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var otherInfoTextView: UITextView!
    
    private var saveButton = UIButton(type: .custom)
    
    var activityIndicator = UIActivityIndicatorView()
    var profile: UserProfile?
    
    private var canEdit = false
    
    //Logged in firebase user
    private var firebaseUser: User? {
        return Auth.auth().currentUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = L("profile_screen_title")
        form.canEdit(false)
        updateTextView(false)
        setupLabels()
        setupTextFields()
        setupObservers()
        renderData()
        setupRightBarItem()
        
        scrollView.keyboardDismissMode = .interactive
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    func setupRightBarItem() {
        let title = canEdit ? L("profile_save_button_title") : L("button_edit")
        saveButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        saveButton.setTitleColor(#colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1), for: .normal)
        saveButton.setTitle(title, for: .normal)
        saveButton.addTarget(self, action: #selector(didPressSave), for: .touchUpInside)
        let rightBarItem = UIBarButtonItem(customView: saveButton)
        navigationItem.rightBarButtonItem = rightBarItem
    }
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 60
        scrollView.contentInset = contentInset
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
    }
    func setupTextFields() {
        form.setOptionalInput(key: "firstName", isOptional: false)
        form.setOptionalInput(key: "lastName", isOptional: false)
        form.setOptionalInput(key: "dob", isOptional: false)
        form.setOptionalInput(key: "gender", isOptional: false)
        form.setOptionalInput(key: "nationality", isOptional: false)
        form.setOptionalInput(key: "contactInfo", isOptional: false)
        
        let dobField = form.control(for: "dob") as? TextField
        dobField?.setRightView(image: UIImage(named: "calendar-icon")!)
        
        let genderField = form.control(for: "gender") as? TextField
        genderField?.setRightView(image: UIImage(named: "drop-down-icon")!)
        
        let organDonorField = form.control(for: "organDonor") as? TextField
        organDonorField?.setRightView(image: UIImage(named: "drop-down-icon")!)
    }
    private func setupLabels() {
        titleLabel.text = L("personal_info_title")
        descriptionLabel.text = L("personal_info_byline")
        organDonerTitleLabel.text = L("profile_edit_donor_question")
        organDonerDescriptionLabel.text = L("profile_edit_donor_note")
        postalAddressTitleLabel.text = L("profile_postal_address")
        postalAddressDescriptionLabel.text = L("profile_edit_postal_address_note")
        insuranceSectionTitleLabel.text = L("profile_edit_insurance_title")
        insuranceSectionDescriptionLabel.text = L("profile_edit_insurance_note")
        emergencyContactTitleLabel.text = L("emergency_contacts")
        emergencyContactDescriptionLabel.text = L("profile_edit_emergency_contacts_note")
        otherInfoSectionTitleLabel.text = L("profile_edit_other_title")
        
        form.setPlaceholder("firstName", L("profile_edit_first_name"))
        form.setPlaceholder("lastName", L("profile_edit_last_name"))
        form.setPlaceholder("dob", L("profile_edit_date_of_birth"))
        form.setPlaceholder("gender", L("profile_gender"))
        form.setPlaceholder("ssn", L("profile_edit_ssn"))
        form.setPlaceholder("nationality", L("profile_nationality"))
        form.setPlaceholder("organDoner", L("common_no"))
        form.setPlaceholder("contactInfo", L("profile_edit_phone"))
        form.setPlaceholder("zip", L("profile_zip"))
        form.setPlaceholder("city", L("profile_edit_city"))
        form.setPlaceholder("country", L("profile_country"))
        form.setPlaceholder("address", L("profile_edit_street_address"))
        form.setPlaceholder("type", L("profile_edit_insurance_type"))
        form.setPlaceholder("company", L("profile_insurance_company"))
        form.setPlaceholder("policy", L("profile_policy_number"))
        form.setPlaceholder("phone", L("alarm_phone"))
        form.setPlaceholder("contactName1", L("profile_edit_emergency_contacts_name"))
        form.setPlaceholder("contactPhone1", L("profile_edit_emergency_contacts_phone"))
        form.setPlaceholder("relationship1", L("profile_edit_emergency_contacts_relation"))
        form.setPlaceholder("contactName2", L("profile_edit_emergency_contacts_name"))
        form.setPlaceholder("contactPhone2", L("profile_edit_emergency_contacts_phone"))
        form.setPlaceholder("relationship2", L("profile_edit_emergency_contacts_relation"))
        
        otherInfoTextView.delegate = self
        otherInfoTextView.text = L("profile_edit_other_hint")
        otherInfoTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 0)
        otherInfoTextView.font = UIFont.applicationFonts(name: .proRegular, size: 16)
        
    }
    private func renderData() {
        form.control(for: "firstName")?.text = profile?.firstName ?? profile?.firebaseFirstName(firebaseUser?.displayName)
        form.control(for: "lastName")?.text = profile?.lastName ?? profile?.firebaseLastName(firebaseUser?.displayName)
        if let dob = UserDefaults.standard.string(forKey: Constants.UserDefaults_Key_DOB) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let date = dateFormatter.date(from: dob)
            if let value = date {
                form.control(for: "dob")?.setFormValue(value)
            } else {
                form.control(for: "dob")?.setFormValue(profile?.dob)
            }
        } else {
            form.control(for: "dob")?.setFormValue(profile?.dob)
            UserDefaults.standard.set(profile?.birthDate, forKey: Constants.UserDefaults_Key_DOB)
        }
        form.control(for: "gender")?.setFormValue(profile?.gender)
        form.control(for: "contactInfo")?.text = profile?.phone
        form.control(for: "nationality")?.text = profile?.nationality
        form.control(for: "organDoner")?.setFormValue(profile?.organDonation)
        form.control(for: "ssn")?.text = profile?.ssn
        
        form.control(for: "zip")?.text = profile?.postalAddress?.zipCode
        form.control(for: "city")?.text = profile?.postalAddress?.city
        form.control(for: "country")?.text = profile?.postalAddress?.country
        form.control(for: "address")?.text = profile?.postalAddress?.info
        form.control(for: "type")?.setFormValue(profile?.insurance?.type)
        form.control(for: "company")?.text = profile?.insurance?.company
        form.control(for: "policy")?.text = profile?.insurance?.policy
        form.control(for: "phone")?.text = profile?.insurance?.phone
        
        let firstMergencyContact = profile?.emergencyContact?.first
        let secondMergencyContact = profile?.emergencyContact?.count == 2 ? profile?.emergencyContact?.last : nil
        
        form.control(for: "contactName1")?.text = firstMergencyContact??.name
        form.control(for: "contactPhone1")?.text = firstMergencyContact??.phone
        form.control(for: "relationship1")?.text = firstMergencyContact??.relationship
        form.control(for: "contactName2")?.text = secondMergencyContact??.name
        form.control(for: "contactPhone2")?.text = secondMergencyContact??.phone
        form.control(for: "relationship2")?.text = secondMergencyContact??.relationship
        
        guard let profile = profile, !profile.otherInfo.isEmptyValue else {
            otherInfoTextView.textColor = .lightGray
            return
        }
        otherInfoTextView.textColor = #colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1)
        otherInfoTextView.text = profile.otherInfo
    }
    //MARK: - IBActions
    @objc func didPressSave() {
        canEdit = !canEdit
        if canEdit {
            saveButton.setTitle(L("profile_save_button_title"), for: .normal)
            form.canEdit(true)
            updateTextView(true)
        } else {
            if form.isValid {
                sendEditProfileRequest()
                updateTextView(false)
            } else {
                form.showInputValidation()
                updateTextView(true)
            }
        }
    }
    func updateState(_ state: ApiProvider.State) {
        stopAnimating()
        switch state {
            case .loading:
                startAnimating()
            case .success:
                form.canEdit(false)
                renderData()
                view.endEditing(true)
            case .error(let error):
                showError(error)
        }
    }
    private func startAnimating() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .darkGray
        activityIndicator.hidesWhenStopped = true
        let barButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = barButton
        activityIndicator.startAnimating()
    }
    private func stopAnimating() {
        activityIndicator.stopAnimating()
        setupRightBarItem()
    }
    //MARK: - Show Error
    func showError(_ error: Error) {
        DispatchQueue.main.async { [unowned self] in
            self.displayError(error)
        }
    }
}
extension UserProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = #colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = L("profile_edit_other_hint")
            textView.textColor = .lightGray
        }
    }
    func updateTextView(_ shouldEnable: Bool) {
        otherInfoTextView.isUserInteractionEnabled = shouldEnable
    }
}
//MARK: - API
extension UserProfileViewController {
    private func sendEditProfileRequest() {
        
        view.endEditing(true)
        
        guard var profile = UserProfile(form: form) else {
            showMessagePrompt(L("profile_validation_required_fields"))
            return
        }
        
        profile.otherInfo = otherInfoTextView.text.isEmptyValue ? "" : otherInfoTextView.text
        updateState(.loading)
        ApiProvider
            .default
            .request(Api.postUser(profile))
            .response(UserProfile.self) { [weak self] response in
                if response.response?.statusCode == 200 {
                    self?.reloadProfile()
                } else if let error = response.error {
                    self?.updateState(.error(error))
                }
            }
    }
    private func reloadProfile() {
        ApiProvider
            .default
            .request(Api.getUser)
            .response(UserProfile.self) { [weak self] response in
                if let value = response.value {
                    self?.profile = value
                    self?.updateState(.success)
                    NotificationCenter.default.post(name: .reloadProfile, object: nil, userInfo: ["UserProfile": value])
                } else if let error = response.error {
                    self?.updateState(.error(error))
                }
            }
    }
}
