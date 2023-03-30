//
//  TranslationViewController.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/30/22.
//

import UIKit

class TranslationViewController: UIViewController {

    @IBOutlet weak var translationImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var languageTextField: UITextField!
    
    ///Privates
    private var pickerView = PickerView(frame: .zero)
    //TODO: - For Fetching Record we not gonna implement pagging, setting pageSize to 100
    private var page = 1
    private var pageSize = 100
    private let identifier = "cellId"
    private var primaryTranslations = [RecordItem]()
    private var secondaryTranslations = [RecordItem]()
    private var viewModels = [TableDataSourceModel]()
    
    var recordType: Dashboard.DashboadItemType = .Allergy
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupRightButtonItem(with: nil, image: UIImage(named: "translate_close")) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        setupPickerView()
        setupTableView()
        setupTitle()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLanguages()
        fetchTanslation(nil, isPrimary: true)
        fetchTanslation(nil, isPrimary: false)
    }
    //MARK: - TableView
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TranslateCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
    //MARK: - Title
    private func setupTitle() {
        switch recordType {
            case .Allergy:
                title = L("translate_title_allergies")
            case .Medication:
                title = L("translate_title_medicine")
            case .Diagnosis:
                title = L("translate_title_diagnoses")
            case .Vaccine:
                title = L("translate_title_vaccines")
            default:
                break
        }
    }
    //MARK: - Setup PickerView
    func setupPickerView() {
        languageTextField.inputView = pickerView
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: nil, style: .done, target: self, action: nil)
        toolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        languageTextField.inputAccessoryView = toolBar
        
        pickerView.didSelectLanguage = { [weak self] language in
            self?.languageTextField.text = language.name
            self?.fetchTanslation(language.iso, isPrimary: false)
        }
    }
    @objc func dismissPicker() {
        languageTextField.resignFirstResponder()
    }
    //MARK: - State
    func showLoading() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        translationImageView.isHidden = true
    }
    func hideLoading() {
        activityIndicator.stopAnimating()
        translationImageView.isHidden = false
    }
}
//MARK: - API
extension TranslationViewController {
    func fetchLanguages() {
        ApiProvider
            .default
            .request(Api.getLanguages)
            .response([Language].self) { [weak self] response in
                if let values = response.value {
                    self?.pickerView.reload([], dataSourceType: .language, languages: values)
                } else if let error = response.error {
                    DispatchQueue.main.async {
                        self?.displayError(error)
                    }
                }
            }
    }
    func fetchTanslation(_ language: String?, isPrimary: Bool) {
        showLoading()
        ApiProvider
            .default
            .request(Api.getDashboardItems(page: page, pageSize: pageSize, type: recordType.rawValue, lanugage: language))
            .response(JsonItemList<RecordItem>.self) { [weak self] response in
                self?.hideLoading()
                if let items = response.value?.items {
                    if isPrimary {
                        self?.primaryTranslations = items
                    } else  {
                        self?.secondaryTranslations = items
                        self?.reload(language)
                    }
                } else if let error = response.error {
                    DispatchQueue.main.async {
                        self?.displayError(error)
                    }
                }
            }
    }
    func reload(_ languageCode: String?) {
        //Remove all items first
        viewModels.removeAll()
        primaryTranslations.forEach { primary in
            secondaryTranslations.forEach { secondary in
                //merge both translations into 1 whose code is same
                if (primary.code == secondary.code) {
                    //append only if items doesnt contain that code, or append if languages are same
                    if !(viewModels.contains(where: { $0.code == primary.code })) || languageCode?.lowercased() == Constants.currentLanguage.lowercased() {
                        viewModels.append(TableDataSourceModel(primaryLanguage: primary.description, secondaryLanguage: secondary.description, code: primary.code))
                    }
                }
            }
        }
        tableView.reloadData()
    }
}
//MARK: - UITableView
extension TranslationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TranslateCell
        cell.fill(viewModels[indexPath.row])
        return cell
    }
}
