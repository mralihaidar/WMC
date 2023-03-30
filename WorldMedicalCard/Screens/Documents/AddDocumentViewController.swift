//
//  AddDocumentViewController.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 1/31/22.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import SafariServices

class AddDocumentViewController: UIViewController {
    
    @IBOutlet weak var documentTypeTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionPlaceholderLabel: UILabel!
    @IBOutlet weak var documentTitleTextField: UITextField!
    @IBOutlet weak var documentNameLabel: UILabel!
    @IBOutlet weak var typePlaceholderLabel: UILabel!
    @IBOutlet weak var documentTypeView: UIView!
    @IBOutlet weak var titlePlaceholderLabel: UILabel!
    @IBOutlet weak var documentTitleView: UIView!
    @IBOutlet weak var documentFileView: UIView! {
        didSet {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(documentFileTapped))
            documentFileView.isUserInteractionEnabled = true
            documentFileView.addGestureRecognizer(gestureRecognizer)
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    
    ///Privates
    private var pickerView = PickerView(frame: .zero)
    private var documentCategory: DocumentCategory?
    
    //TODO: - For Fetching Record we not gonna implement pagging, setting pageSize to 100
    private var page = 1
    private var pageSize = 100
    private var isDescriptionEmpty = false
    
    ///Publics
    var documentURL: URL? //url to document that is selected from files
    var document: Document?
    
    private var name: String? {
        get {
            return documentURL?.lastPathComponent
        }
        set {
            documentNameLabel.text = newValue
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategories()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = closeButton
        setupRightButtonItem(with: L("common_save")) { [weak self] in
            self?.saveTapped()
        }
    }
    //MARK: - Setup View
    func setupView() {
        documentNameLabel.text = name
        titlePlaceholderLabel.text = L("add_document_document_title_hint")
        
        documentTitleTextField.attributedPlaceholder = NSAttributedString(string: L("add_document_document_title_hint"),
                                                                          attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4431372549, green: 0.5019607843, blue: 0.5882352941, alpha: 1),
                                                                                       NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        typePlaceholderLabel.text = L("add_document_document_type_hint")
        documentTypeTextField.attributedPlaceholder = NSAttributedString(string: L("add_document_document_type_hint"),
                                                                         attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4431372549, green: 0.5019607843, blue: 0.5882352941, alpha: 1),
                                                                                      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        descriptionPlaceholderLabel.text = L("add_document_description_hint")
        descriptionTextView.delegate = self
        descriptionTextView.text = L("add_document_description_hint")
        descriptionTextView.textColor = #colorLiteral(red: 0.4431372549, green: 0.5019607843, blue: 0.5882352941, alpha: 1)
        
        [documentTitleTextField, documentTypeTextField].forEach {
            $0?.addTarget(self, action: #selector(didValidate), for: .editingChanged)
        }
        didValidate()
        setupPickerView()
        ///For edit the document from dashboard
        setupDocument()
    }
    func setupDocument() {
        getDocument()
        guard let document = self.document else {
            return
        }
        documentNameLabel.text = document.fileName
        documentTitleTextField.text = document.fileTitle
        titlePlaceholderLabel.isHidden = document.fileTitle.isEmpty
        
        descriptionTextView.text = document.fileDescription
        if document.fileDescription != nil {
            isDescriptionEmpty = false
            showDescriptionPlaceholder()
        } else {
            descriptionTextView.text = L("add_document_description_hint")
            descriptionTextView.textColor = #colorLiteral(red: 0.4431372549, green: 0.5019607843, blue: 0.5882352941, alpha: 1)
        }
        documentTypeTextField.text = document.fileCatagory
        typePlaceholderLabel.isHidden = false
    }
    
    func toggleUploadloading(_ isLoading: Bool) {
        if isLoading {
            let loadingView = UIActivityIndicatorView()
            loadingView.startAnimating()
            self.navigationItem.rightBarButtonItem?.customView = loadingView
        } else {
            self.navigationItem.rightBarButtonItem?.customView = nil
            self.navigationItem.rightBarButtonItem?.title = L("common_save")
        }
    }
    
    //MARK: - Setup PickerView
    func setupPickerView() {
        documentTypeTextField.inputView = pickerView
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: nil, style: .done, target: self, action: nil)
        toolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        documentTypeTextField.inputAccessoryView = toolBar
        
        pickerView.didSelect = { [weak self] category in
            self?.selectedDocumentCategory(category)
        }
    }
    //MARK: - IBActions
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    @objc func saveTapped() {
        //if the document is nil we need to upload a new one, else edit the existing
        document == nil ? uploadDocument() : editDocument()
    }
    @objc func documentFileTapped() {
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
    @objc func dismissPicker() {
        documentTypeTextField.resignFirstResponder()

        if let category = pickerView.selectedCategory() {
            selectedDocumentCategory(category)
        }
    }
    //MARK: - Validate
    //Enable or disable save button
    func enable() {
        navigationController?.navigationItem.rightBarButtonItem?.isEnabled = true
        navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], for: .normal)
    }
    func disable() {
        navigationController?.navigationItem.rightBarButtonItem?.isEnabled = false
        navigationController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue.withAlphaComponent(0.5)], for: .disabled)
    }
    @objc func didValidate() {
        guard let title = documentTitleTextField.text, !title.isEmpty,
              let type = documentTypeTextField.text, !type.isEmpty else {
                  disable()
                  return
              }
        enable()
    }
    ///Hide/show placeholders of UITextField
    func hidePlaceholders() {
        guard let document = document else {
            typePlaceholderLabel.isHidden = true
            titlePlaceholderLabel.isHidden = true
            descriptionPlaceholderLabel.isHidden = true
            return
        }
        typePlaceholderLabel.isHidden = false
        titlePlaceholderLabel.isHidden = document.fileTitle.isEmpty
        if isDescriptionEmpty {
            showDescriptionPlaceholder()
        }
    }

    private func selectedDocumentCategory(_ category: DocumentCategory) {
        documentCategory = category
        documentTypeTextField.text = category.categoryText
        didValidate()
    }
}
//MARK: - TextView delegate
extension AddDocumentViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        hidePlaceholders()
        if textView.textColor == #colorLiteral(red: 0.4431372549, green: 0.5019607843, blue: 0.5882352941, alpha: 1) {
            descriptionPlaceholderLabel.isHidden = false
            textView.text = nil
            textView.textColor = #colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1)
            isDescriptionEmpty = false
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = L("add_document_description_hint")
            textView.textColor = #colorLiteral(red: 0.4431372549, green: 0.5019607843, blue: 0.5882352941, alpha: 1)
            isDescriptionEmpty = true
        }
    }
    func showDescriptionPlaceholder() {
        descriptionTextView.textColor = #colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1)
        descriptionPlaceholderLabel.isHidden = false
    }
}
//MARK: - TextField Delegate
extension AddDocumentViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hidePlaceholders()
        if textField == documentTypeTextField {
            typePlaceholderLabel.isHidden = false
        } else if textField == documentTitleTextField {
            titlePlaceholderLabel.isHidden = false
        }
    }
}
//MARK: - Document Picker Delegate
extension AddDocumentViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func showDocumentPicker() {
        let types = [kUTTypePDF, kUTTypeText, kUTTypeRTF, kUTTypeSpreadsheet, kUTTypePlainText, kUTTypeDiskImage, kUTTypePNG, kUTTypeJPEG, kUTTypeImage, kUTTypeJPEG2000, kUTTypeLivePhoto]
        let viewController = UIDocumentPickerViewController(documentTypes: types as [String], in: .open)
        viewController.delegate = self
        viewController.modalPresentationStyle = .formSheet
        present(viewController, animated: true, completion: nil)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let documentUrl = urls.first {
            controller.dismiss(animated: true) { [weak self] in
                self?.documentURL = FileManager.saveDocument(for: documentUrl)
                self?.name = self?.documentURL?.lastPathComponent
            }
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension AddDocumentViewController: UIImagePickerControllerDelegate {
    
    func showPhotoPicker(type: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.mediaTypes = ["public.image"]
        picker.sourceType = type
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        
        dismiss(animated: true) {
            self.documentURL = FileManager.saveDocumentImage(image: image)
            self.name = self.documentURL?.lastPathComponent
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

//MARK: - Document Type - API
extension AddDocumentViewController {
    func fetchCategories() {
        ApiProvider
            .default
            .request(Api.getDocumentCategories(page: page, pageSize: pageSize))
            .response(JsonItemList<DocumentCategory>.self) { [weak self] response in
                if let result = response.value {
                    self?.pickerView.reload(result.items, dataSourceType: .documentCategory, languages: [])
                    ///In case of editing the document
                    self?.getDocumentCategory(from: result.items)
                    self?.documentCategory = result.items.last
                    self?.documentTypeTextField.text = result.items.last?.categoryText
                } else if let error = response.error {
                    DispatchQueue.main.async {
                        self?.displayError(error)
                    }
                }
            }
    }
    //
    func getDocumentCategory(from list: [DocumentCategory]) {
        guard let document = self.document else {
            return
        }
        if let id = list.filter({ $0.categoryText == document.fileCatagory }).first?.id, let category = document.fileCatagory {
            self.documentCategory = DocumentCategory(id: id, categoryText: category)
        }
    }
}
//MARK:  - Document upload - API
extension AddDocumentViewController {
    func uploadDocument() {
        guard let documentUrl = self.documentURL,
              let title = documentTitleTextField.text,
              let categoryId = documentCategory?.id else {
                  return
              }
        
        let data = try? Data(contentsOf: documentUrl)
        
        toggleUploadloading(true)
        ApiProvider
            .default
            .upload(Api.postDocument,
                    fileName: name ?? "Nameofthefile",
                    data: data,
                    mimeType: mimeType(for: documentUrl.lastPathComponent),
                    fileTitle: title,
                    fileDescription: isDescriptionEmpty ? nil : descriptionTextView.text,
                    categoryId: categoryId)
            .response(Document.self) { [weak self] response in
                self?.toggleUploadloading(false)
                
                if let _ = response.value {
                    NotificationCenter.default.post(name: .reloadRecords, object: nil)
                    self?.dismiss(animated: true, completion: nil)
                } else if let error = response.error {
                    DispatchQueue.main.async {
                        self?.displayError(error)
                    }
                }
            }
    }
    func editDocument() {
        guard let url = self.documentURL,
              let title = documentTitleTextField.text,
              let categoryId = documentCategory?.id,
              let document = document else {
                  return
              }
        let data = try? Data(contentsOf: url)
        
        toggleUploadloading(true)
        ApiProvider
            .default
            .upload(Api.editDocument(String(document.fileId)),
                    fileName: name ?? "name of file when edit",
                    data: data,
                    mimeType: document.fileExtension,
                    fileTitle: title,
                    fileDescription: isDescriptionEmpty ? nil : descriptionTextView.text,
                    categoryId: categoryId)
            .response(Document.self) { [weak self] response in
                self?.toggleUploadloading(false)
                if let _ = response.value {
                    NotificationCenter.default.post(name: .reloadRecords, object: nil)
                    self?.dismiss(animated: true, completion: nil)
                } else if let error = response.error {
                    DispatchQueue.main.async {
                        self?.displayError(error)
                    }
                }
            }
    }
    
    ///download the actual document which needs to be edited
    func getDocument() {
        guard let document = document else {
            return
        }
        ApiProvider
            .default
            .download(Api.getDocument(String(document.fileId)))
            .response { [weak self] downloadResponse in
                if let value = downloadResponse.fileURL, let documentUrl = FileManager.saveDocument(for: value) {
                    self?.documentURL = documentUrl
                } else if let error = downloadResponse.error {
                    DispatchQueue.main.async {
                        self?.displayError(error)
                    }
                }
            }
    }
    private func mimeType(for path: String) -> String {
        let pathExtension = URL(fileURLWithPath: path).pathExtension as NSString
        guard
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil)?.takeRetainedValue(),
            let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue()
        else {
            return "application/octet-stream"
        }
        
        return mimetype as String
    }
}

