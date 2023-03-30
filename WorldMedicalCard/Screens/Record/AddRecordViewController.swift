//
//  AddRecordViewController.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 1/26/22.
//

import UIKit

class AddRecordViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    ///Privates
    private var cellId = "cellId"
    private var recordItems = [RecordItem]()
    
    private var page = 1
    private var pageSize = 10
    private var total = 0
    private var searchText = ""
    
    ///Publics
    var recordType: Dashboard.DashboadItemType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        fetchRecordItems()
        setupNotificationObserver()
    }
    //MARK: - Setup View
    func setupView() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = closeButton
        switch recordType {
            case .Allergy:
                titleLabel.text = L("add_new_allergy_title")
            case .Diagnosis:
                titleLabel.text = L("add_new_diagnoses_title")
            case .Medication:
                titleLabel.text = L("add_new_medicine_title")
            case .Vaccine:
                titleLabel.text = L("add_new_vaccines_title")
            default:
                break
        }
        searchTextField.attributedPlaceholder = NSAttributedString(string: L("add_new_search_hint"),
                                                                   attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5),
                                                                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)])
        searchTextField.addTarget(self, action: #selector(didSearch), for: .editingChanged)
        searchTextField.delegate = self
    }
    //MARK: - IBAction
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    //MARK: - Keyboard Observers
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.25) {
            self.tableViewBottomConstraint.constant = keyboardFrame.height + self.view.safeAreaInsets.bottom
            self.view.layoutIfNeeded()
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        self.tableViewBottomConstraint.constant = 0
    }
    //MARK: - Reload TableView
    private func reloadTableView() {
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
    }
}
//MARK: - TableView Delegate methods
extension AddRecordViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordItems.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return L("add_new_allergy_top_hits") //top hits header
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.contentView.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            cell.textLabel?.textColor = .black
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .none
            cell.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        }
        cell.textLabel?.text = recordItems[indexPath.row].description
        cell.detailTextLabel?.text = recordItems[indexPath.row].code
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Call api whenever user go end of tableview indexPath
        if indexPath.row == recordItems.count - 1 {
            if self.total > recordItems.count {
                if let text = searchTextField.text {
                    searchRecord(text)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = recordItems[indexPath.row]
        postRecord(item)
    }
    //MARK: - Show Error
    private func showError(_ error: Error) {
        DispatchQueue.main.async { [unowned self] in
            self.displayError(error)
        }
    }
}
//MARK: - API - Fetch
extension AddRecordViewController {
    func searchRecord(_ text: String) {
        ApiProvider
            .default
            .request(Api.getRecordItems(text: text,
                                        page: page,
                                        pageSize: pageSize,
                                        type: recordType.rawValue))
            .response(JsonItemList<RecordItem>.self) { [weak self] response in
                if let value = response.value {
                    self?.searchText = text
                    self?.update(value)
                }  else if let error = response.error {
                    self?.showError(error)
                }
            }
    }
    func update(_ result: JsonItemList<RecordItem>) {
        self.total = result.total
        page += 1 //increment page
        self.recordItems += result.items
        if searchText.isEmpty {
            resetSearch()
        }
        reloadTableView()
    }
    func resetSearch() {
        //Reset the search when input text is empty
        page = 1
        pageSize = 10
        total = 0
        recordItems.removeAll()
        reloadTableView()
    }
}
//MARK: - Search
extension AddRecordViewController: UITextFieldDelegate {
    @objc func didSearch() {
        guard let  text = searchTextField.text else {
            page = 1
            pageSize = 10
            return
        }
        //We should have a fresh api call when user type text
        resetSearch()
        searchRecord(text)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
//MARK: - POST - API
extension AddRecordViewController {
    func postRecord(_ item: RecordItem) {
        ApiProvider
            .default
            .request(Api.postRecordItems(recordType.rawValue, recordItem: item))
            .response { [weak self] response in
                if let error = response.error {
                    self?.showError(error)
                } else {
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: .reloadRecords, object: nil)
                        })
                    }
                }
            }
    }
}
