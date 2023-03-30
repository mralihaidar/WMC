//
//  DashboardViewController.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 1/20/22.
//

import UIKit
import MobileCoreServices
import Kingfisher
import FirebaseAuth
import UniformTypeIdentifiers
import LinkPresentation
import Alamofire
import SafariServices

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileDescriptionLabel: UILabel!
    @IBOutlet weak var profileIncompleteLabel: UILabel!
    @IBOutlet weak var completeProfileLabel: UILabel!
    @IBOutlet weak var subscribeNowView: UIView!
    @IBOutlet weak var noSubscriptionLabel: UILabel!
    @IBOutlet weak var subscribeDescriptionLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var tableView: DashboardTableView!
    @IBOutlet weak var profileView: UIView! {
        didSet {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileViewTapped))
            profileView.isUserInteractionEnabled = true
            profileView.addGestureRecognizer(gestureRecognizer)
        }
    }
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var subscriptionButton: UIButton!
    @IBOutlet weak var moreOptionsView: UIView!
    @IBOutlet weak var nameInitialsView: UIView!
    @IBOutlet weak var nameInitialsLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var cardImageView: UIView! {
        didSet {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cardViewTapped))
            cardImageView.isUserInteractionEnabled = true
            cardImageView.addGestureRecognizer(gestureRecognizer)
        }
    }
    @IBOutlet weak var orderSuccessfullLabel: UILabel!
    @IBOutlet weak var incompleteProfileView: UIView!
    @IBOutlet weak var cardMainContentView: UIStackView!
    @IBOutlet weak var orderCardView: UIView!
    @IBOutlet weak var orderCardLabel: UILabel!
    @IBOutlet weak var orderCardDescription: UILabel!
    @IBOutlet weak var orderNowButton: UIButton!
    @IBOutlet weak var orderLaterButton: UIButton!
    @IBOutlet weak var reOrderButton: UIButton!
    @IBOutlet weak var reOrderCardUnavailableView: UIView!
    @IBOutlet weak var reOrderCardUnavailableLabel: UILabel!
    @IBOutlet weak var orderCardLoadingView: UIActivityIndicatorView!
    
    private let cellId = "DashboardProfileCell"
    private let headerId = "DashboardHeaderView"
    private var dismissOptionsViewGesture = UIGestureRecognizer()
    
    private var contentOffsetObservingToken: NSKeyValueObservation?
    ///publics
    var user: UserProfile?
    
    //TODO: - For Fetching Record we not gonna implement pagging, setting pageSize to 100
    private var page = 1
    private var pageSize = 100
    private var isCardViewShown = true //default is shown
    
    //Logged in firebase user
    private var firebaseUser: User? {
        return Auth.auth().currentUser
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTitleLabel()
        setupTableView()
        setupRightButtonItem(with: nil, image: #imageLiteral(resourceName: "dashbord-more")) { [weak self] in
            self?.moreOptionsTapped()
        }
        //        fetchAllRecord(shouldShowLoading: true) //Added after getting profile
        NotificationCenter.default.addObserver(forName: .reloadProfile, object: nil, queue: .main) { [weak self] notification in
            if let user = notification.userInfo?["UserProfile"] as? UserProfile {
                self?.reloadUser(user)
            } else {
                self?.fetchUserProfile()
            }
        }
        NotificationCenter.default.addObserver(forName: .reloadRecords, object: nil, queue: .main) { [weak self] _ in
            self?.fetchAllRecord(shouldShowLoading: false)
        }
        setupNavigationAppearance()
        
        tableView.contentInset.top = headerView.frame.height
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        moreOptionsView.isHidden = true
        subscribeNowView.isHidden = true
        fetchUserProfile()
    }
    
    override var navigationItemBackButtonTextIsHidden: Bool { return true }
    
    //MARK: - Setup View
    func setupView() {
        profileIncompleteLabel.text = L("title_your_profile_is_incomplete")
        profileDescriptionLabel.text = L("description_your_profile_is_incomplete")
        completeProfileLabel.text = L("complete_your_profile")
        
        noSubscriptionLabel.text = L("no_subscription_title")
        subscribeDescriptionLabel.text = L("no_subscription_description")
        subscribeButton.setTitle(L("subscribe_button"), for: .normal)
        
        signOutButton.setTitle(L("sign_out_button"), for: .normal)
        termsButton.setTitle(L("terms_and_conditions_button"), for: .normal)
        subscribeButton.setTitle(L("subscription_overview_title"), for: .normal)
        
        orderSuccessfullLabel.text = L("wmc_order_successful")
        orderCardLabel.text = L("order_your_card_title")
        orderCardDescription.text = L("order_your_card_description")
        orderNowButton.setTitle(L("order_now_button"), for: .normal)
        orderLaterButton.setTitle(L("maybe_later_button"), for: .normal)
        reOrderButton.setTitle(L("wmc_card_menu_reorder_card"), for: .normal)
        
        dismissOptionsViewGesture = UITapGestureRecognizer(target: self, action: #selector(hideMoreOptionsView))
        view.isUserInteractionEnabled = true
        
        orderCardLoadingView.hidesWhenStopped = true
    }
    func checkSubscription(_ user: UserProfile) {
        DispatchQueue.main.async {
            self.setupUser(user)
            guard  user.isActiveSubscription ?? false else {
                self.tableView.alpha = 0.5
                self.tableView.isUserInteractionEnabled = false
                self.subscribeNowView.isHidden = false
                return
            }
            self.subscribeNowView.isHidden = true
            self.tableView.alpha = 1.0
            self.tableView.isUserInteractionEnabled = true
        }
    }
    func setupMembershipCard(_ user: UserProfile) {
        let status = user.orderStatus
        let isCardAlreadyOrdered = (status == .Completed) || (status == .Registered)
        let isProfileOK = user.isValidToOrderCard()
        
        let reorderCardAvailableInDays = user.reorderCardAvailableInDays ?? 0
        
        orderSuccessfullLabel.isHidden = !isCardAlreadyOrdered
        orderCardView.isHidden = isCardAlreadyOrdered || !isProfileOK
        
        reOrderButton.isHidden = !(isCardAlreadyOrdered && reorderCardAvailableInDays == 0 && isProfileOK)

        reOrderCardUnavailableView.isHidden = !reOrderButton.isHidden || !isProfileOK || !orderCardView.isHidden
        reOrderCardUnavailableLabel.text = String(format: L("card_reorder_period_title"), reorderCardAvailableInDays)
    }
    func setupTableView() {
        tableView.didAdd = { recordType in
            switch recordType {
            case .Allergy, .Medication, .Diagnosis, .Vaccine:
                self.showAddRecordController(for: recordType)
            case .Documents:
                self.showDocumentPickerSelection()
            }
        }
        tableView.didShare = { [weak self] recordType in
            self?.shareRecord(recordType)
        }
        
        tableView.didDeleteRecord = { [weak self] item in
            self?.deleteRecord(item)
        }
        
        tableView.didTranslateRecord = { [weak self] recordType in
            self?.showTranslations(for: recordType)
        }
        ///Document
        tableView.didDeleteDocument = { [weak self] document in
            self?.deleteDocument(for: document)
        }
        tableView.didEditDocument = { [weak self] document in
            self?.showEditDocument(document)
        }
        tableView.didSelectDocument = { [weak self] document in
            self?.showDocumentDetails(document)
        }
        tableView.didShareDocument = { [weak self] document in
            self?.getDocument(document)
        }
    }
    func setupTitleLabel() {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.text = Date().timeOfTheDay
        let item = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = item
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1184316501, green: 0.131714195, blue: 0.1830610037, alpha: 1)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    func setupUser(_ user: UserProfile) {
        if let fullName = user.fullName {
            userNameLabel.text = fullName
        } else {
            userNameLabel.text = firebaseUser?.displayName
        }
        let date = user.memberSinceDate
        if user.isProfileComplete { //complete profile
            completeProfileLabel.text = String(format: L("member_since"), date?.string() ?? "")
            incompleteProfileView.isHidden = true
            cardMainContentView.isHidden = false
        } else { //incomplete profile
            incompleteProfileView.isHidden = false
            completeProfileLabel.text = L("complete_your_profile")
            completeProfileLabel.textColor = .red
            cardMainContentView.isHidden = true
        }
        if let image = user.avatar, let url = URL(string: image) {
            nameInitialsView.isHidden = true
            profileImageView.isHidden = false
            profileImageView.kf.setImage(with: url)
        } else if let photo = firebaseUser?.photoURL {
            nameInitialsView.isHidden = true
            profileImageView.isHidden = false
            profileImageView.kf.setImage(with: photo)
        } else {
            nameInitialsView.isHidden = false
            profileImageView.isHidden = true
            nameInitialsLabel.text = user.nameInitials
        }
        
        layoutHeader()
    }
    
    private func layoutHeader() {
        view.layoutIfNeeded()
        
        tableView.contentInset.top = headerView.frame.height
        tableView.contentOffset.y = -headerView.frame.height
        tableView.verticalScrollIndicatorInsets.top = headerView.frame.height
        
        contentOffsetObservingToken = tableView.observe(\.contentOffset, options: .new) { [weak self] _, value in
            guard let self = self else { return }
            if let contentOffset = value.newValue {
                let y = contentOffset.y + self.tableView.contentInset.top
                self.headerViewTopConstraint.constant = -y
            }
        }
    }
    
    //MARK: - IBActions
    @IBAction func subscribeNowTapped(_ sender: Any) {
        let sf = SFSafariViewController(url: Environment.subscriptionUrl)
        present(sf, animated: true)
    }
    @objc func profileViewTapped() {
        let viewController = UserProfileViewController.instantiateFrom(storyboard: .profile)
        viewController.profile = user
        show(viewController, sender: self)
    }
    @objc func cardViewTapped() {
        let status = user?.orderStatus
        let isCardAlreadyOrdered = (status == .Completed) || (status == .Registered)
        if isCardAlreadyOrdered {
            //Should not be able to tap if already ordered card
            return
        }
        isCardViewShown = !isCardViewShown
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .transitionCrossDissolve, animations: {
            self.orderCardView.isHidden = !self.isCardViewShown
            self.orderCardView.alpha = self.isCardViewShown ? 1.0 : 0.0
        }, completion: nil)
    }
    @objc func moreOptionsTapped() {
        //Gesture should be available only when more options is shown
        view.addGestureRecognizer(dismissOptionsViewGesture)
        moreOptionsView.isHidden = false
    }
    @objc func hideMoreOptionsView() {
        //Remove the Gesture when more options is hidden, so we can have touch on uitableview
        view.removeGestureRecognizer(dismissOptionsViewGesture)
        moreOptionsView.isHidden = true
    }
    @IBAction func signOutTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .logoutUser, object: nil)
    }
    @IBAction func termsConditionsTapped(_ sender: Any) {
        showTerms()
    }
    @IBAction func subscriptionTapped(_ sender: UIButton) {
        let subscriptions = SubscriptionsViewController.instantiateFrom(storyboard: .subscription)
        subscriptions.user = self.user
        navigationController?.pushViewController(subscriptions, animated: true)
    }
    @IBAction func didPressOrderNow(_ sender: Any) {
        orderCard()
    }
    @IBAction func didPressOrderLater(_ sender: Any) {
        cardViewTapped()
    }
    @IBAction func reOrderButtonPressed(_ sender: UIButton) {
        orderCard()
    }
    
    //MARK: - Navigation
    func showTerms() {
        let viewController = TermsAndConditionsViewController.instantiateFrom(storyboard: .appTour)
        viewController.isFromDashboard = true
        show(viewController, sender: self)
    }
    func showAddRecordController(for recordType: Dashboard.DashboadItemType) {
        let viewController = AddRecordViewController.instantiateFrom(storyboard: .dashboard)
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.recordType = recordType
        present(navigationController, animated: true, completion: nil)
    }
    
    func showDocumentPickerSelection() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: L("common_photolibrary"), style: .default, handler: { _ in
            self.showPhotoPicker(type: .photoLibrary)
        }))
        
        alert.addAction(UIAlertAction(title: L("common_takephoto"), style: .default, handler: { _ in
            self.showPhotoPicker(type: .camera)
        }))
        
        alert.addAction(UIAlertAction(title: L("common_choosefile"), style: .default, handler: { _ in
            self.showDocumentPicker()
        }))
        alert.addAction(UIAlertAction(title: L("common_cancel"), style: .cancel))
        present(alert, animated: true)
    }
    
    func showDocumentPicker() {
        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet, kUTTypePlainText, kUTTypeDiskImage, kUTTypePNG, kUTTypeJPEG, kUTTypeImage, kUTTypeJPEG2000, kUTTypeLivePhoto]
        let viewController = UIDocumentPickerViewController(documentTypes: types as [String], in: .open)
        viewController.delegate = self
        viewController.modalPresentationStyle = .formSheet
        present(viewController, animated: true, completion: nil)
    }
    
    func showPhotoPicker(type: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.mediaTypes = ["public.image"]
        picker.sourceType = type
        present(picker, animated: true)
    }
    
    func showEditDocument(_ document: Document) {
        let viewController = AddDocumentViewController.instantiateFrom(storyboard: .dashboard)
        viewController.document = document
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
    func showDocumentDetails(_ document: Document) {
        let viewController = DocumentDetailViewController.instantiateFrom(storyboard: .dashboard)
        viewController.document = document
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
    func showTranslations(for recordType: Dashboard.DashboadItemType) {
        let viewController = TranslationViewController(nibName: "TranslationViewController", bundle: nil)
        viewController.recordType = recordType
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
    //MARK: - User profile
    private func fetchUserProfile() {
        if user == nil {
            showLoading()
        }
        ApiProvider
            .default
            .request(Api.getUser)
            .response(UserProfile.self) { [weak self] response in
                self?.hideLoading()
                if let user = response.value {
                    self?.reloadUser(user)
                } else if let error = response.error {
                    self?.showError(error)
                }
            }
    }
    
    private func reloadUser(_ user: UserProfile) {
        self.user = user
        fetchAllRecord(shouldShowLoading: user.isForcedRefreshToken == true)
        checkSubscription(user)
        setupMembershipCard(user)
    }

    //MARK: - Show Error
    private func showError(_ error: Error) {
        DispatchQueue.main.async { [unowned self] in
            self.displayError(error)
        }
    }
    //MARK: - Loading
    func showLoading() {
        loadingView.isHidden = false
    }
    func hideLoading() {
        loadingView.isHidden = true
    }
    func showOrderLoading() {
        orderNowButton.isHidden = true
        view.isUserInteractionEnabled = false
        orderCardLoadingView.startAnimating()
    }
    func hideOrderLoading() {
        orderNowButton.isHidden = false
        view.isUserInteractionEnabled = true
        orderCardLoadingView.stopAnimating()
    }
}
//MARK: - Document Picker Delegate - URL
extension DashboardViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true) { [weak self] in
            let viewController = AddDocumentViewController.instantiateFrom(storyboard: .dashboard)
            viewController.documentURL = FileManager.saveDocument(for: urls.first)
            let navigationController = UINavigationController(rootViewController: viewController)
            self?.present(navigationController, animated: true, completion: nil)
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension DashboardViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        
        let viewController = AddDocumentViewController.instantiateFrom(storyboard: .dashboard)
        viewController.documentURL = FileManager.saveDocumentImage(image: image)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        dismiss(animated: true) {
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

//MARK: - Get Records API
extension DashboardViewController {
    
    typealias RecordFetchResult = DataResponse<[RecordItem], AFError>
    
    func fetchRecord(_ type: Dashboard.DashboadItemType, completion: @escaping (RecordFetchResult) -> Void) {
        ApiProvider
            .default
            .request(Api.getDashboardItems(page: page, pageSize: pageSize, type: type.rawValue, lanugage: nil))
            .response(JsonItemList<RecordItem>.self) { response in
                completion(response.map { $0.items })
            }
    }
    func fetchDocuments(completion: @escaping (RecordFetchResult) -> Void) {
        ApiProvider
            .default
            .request(Api.getDocuments(page: page, pageSize: pageSize))
            .response(JsonItemList<Document>.self) { response in
                
                let res = response.map {
                    $0.items.map {
                        RecordItem(code: "", description: "", document: $0)
                    }
                }
                
                completion(res)
            }
    }
    func fetchAllRecord(shouldShowLoading: Bool) {
        if shouldShowLoading {
            showLoading()
        }
        
        let group = DispatchGroup()
        
        let loadingTypes: [Dashboard.DashboadItemType] = [
            .Allergy, .Medication, .Diagnosis, .Vaccine
        ]
        
        var alergies = [RecordItem]()
        var medications = [RecordItem]()
        var diagnosis = [RecordItem]()
        var vaccines = [RecordItem]()
        var documents = [RecordItem]()
        
        var error: Error?
        
        loadingTypes.forEach { type in
            group.enter()
            fetchRecord(type) { result in
                group.leave()
                if let items = result.value {
                    switch type {
                    case .Allergy: alergies = items
                    case .Medication: medications = items
                    case .Diagnosis: diagnosis = items
                    case .Vaccine: vaccines = items
                    case .Documents: break // won't happen
                    }
                } else {
                    error = result.error
                }
            }
        }
        
        group.enter()
        fetchDocuments { result in
            group.leave()
            if let items = result.value {
                documents = items
            } else {
                error = result.error
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.hideLoading()
            self?.tableView.reload(alergies: alergies, medications: medications, diagnosis: diagnosis, vaccines: vaccines, documents: documents)
            
            // if error -> show error
            if let error = error {
                print("load content error \(error)")
            }
        }
    }
}
//MARK: - Delete Record API
extension DashboardViewController {
    func deleteRecord(_ item: RecordDeleteItem) {
        
        ApiProvider
            .default
            .request(Api.deleteRecordItem(item.type.rawValue, recordItem: item.recordItem))
            .response { [weak self] response in
                if let error = response.error {
                    DispatchQueue.main.async {
                        self?.showError(error)
                    }
                } else {
                    self?.tableView.deleteRecordItem(item)
                }
            }
    }
    func deleteDocument(for document: Document) {
        ApiProvider
            .default
            .request(Api.deleteDocument(String(document.fileId)))
            .response { [weak self] response in
                if let error = response.error {
                    self?.showError(error)
                } else {
                    self?.tableView.deleteRecordItem(RecordDeleteItem(type: .Documents, recordItem: RecordItem(code: "", description: "", document: document)))
                }
            }
    }
}
//MARK: - Share
extension DashboardViewController {
    func shareRecord(_ recordType: Dashboard.DashboadItemType) {
        showLoading()
        let type = recordType.rawValue
        ApiProvider
            .default
            .download(Api.share(type, outputFormat: "image"))
            .response { [weak self] response in
                self?.hideLoading()
                if let url = response.fileURL {
                    if let data = try? Data(contentsOf: url) {
                        let image = UIImage(data: data)
                        self?.didShareRecord(image, title: recordType.rawValue)
                    }
                } else if let error = response.error {
                    self?.showError(error)
                }
            }
    }
    func didShareRecord(_ metaData: Any?, title: String) {
        if let metaData = metaData {
            let item = ActivityItemSource(title: title, metaData: metaData)
            let shareController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
            present(shareController, animated: true)
        }
    }
    ///download the actual document which needs to be shared
    func getDocument(_ document: Document) {
        showLoading()
        ApiProvider
            .default
            .download(Api.getDocument(String(document.fileId)))
            .response { [weak self] downloadResponse in
                self?.hideLoading()
                if let value = downloadResponse.fileURL {
                    if let data = try? Data(contentsOf: value) {
                        self?.didShareRecord(data, title: document.fileTitle)
                    }
                } else if let error = downloadResponse.error {
                    DispatchQueue.main.async {
                        self?.displayError(error)
                    }
                }
            }
    }
}
//MARK: - Card
extension DashboardViewController {
    func orderCard() {
        showOrderLoading()
        ApiProvider
            .default
            .request(Api.postOrderCard)
            .response { [weak self] response in
                self?.hideOrderLoading()
                if let error = response.error {
                    DispatchQueue.main.async {
                        self?.displayError(error)
                    }
                } else {
                    self?.fetchUserProfile()
                }
            }
    }
}
