//
//  DocumentDetailViewController.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/21/22.
//

import UIKit
import PDFKit

class DocumentDetailViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var documentImageView: UIImageView!
    var document: Document!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = document.fileTitle
        download()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backItem = UIBarButtonItem(title: L("common_cancel"), style: .plain, target: self, action: #selector(didPressCancel))
        navigationItem.rightBarButtonItem = backItem
        documentImageView.contentMode = .scaleAspectFit
        documentImageView.layer.masksToBounds = true
        documentImageView.clipsToBounds = true
        setupNavigationAppearance()
    }
    @objc func didPressCancel() {
        dismiss(animated: true, completion: nil)
    }
}
//MARK: - API
private extension DocumentDetailViewController {
    ///download the actual document which needs to be edited
    func download() {
        activityIndicatorView.startAnimating()
        ApiProvider
            .default
            .download(Api.getDocument(String(document.fileId)))
            .response { [weak self] downloadResponse in
                self?.activityIndicatorView.stopAnimating()
                if let value = downloadResponse.fileURL {
                    self?.reload(value)
                } else if let error = downloadResponse.error {
                    DispatchQueue.main.async {
                        self?.displayError(error)
                    }
                }
            }
    }
    func reload(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            if url.pathExtension == "pdf" {
                setupPDF(data)
            } else {
                let image = UIImage(data: data)
                documentImageView.image = image
            }
        } catch(let err) {
            print("Error converting url", err)
        }
    }
    func setupPDF(_ data: Data) {
        let pdfDocument = PDFDocument(data: data)
        let pdfView = PDFView(frame: documentImageView.frame)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.backgroundColor = .clear
        view.addSubview(pdfView)
        pdfView.displayMode = .singlePageContinuous
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        pdfView.document = pdfDocument
    }
}
