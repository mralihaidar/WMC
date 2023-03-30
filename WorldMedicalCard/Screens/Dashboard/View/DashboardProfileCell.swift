//
//  DashboardProfileCell.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 1/21/22.
//

import UIKit
import Alamofire

class DashboardProfileCell: UITableViewCell {
    
    @IBOutlet weak var itemDescriptionStackView: UIStackView!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: RecordTableView!
    
    func fill(sectionDisplayable data: Dashboard.SectionDisplayable) {

        let section = data.section
        let noItemsText: String
        
        switch section.recordType {
            case .Allergy:
                noItemsText = L("no_allergies_listed")
            case .Medication:
                noItemsText = L("no_medications_listed")
            case .Diagnosis:
                noItemsText = L("no_diagnoses_listed")
            case .Vaccine:
                noItemsText = L("no_vaccines_listed")
            case .Documents:
                noItemsText = L("no_documents_added")
        }
        
        tableView.reload(dashboardSection: section)
        
        if section.isEmpty {
            itemDescriptionStackView.isHidden = false
            itemDescriptionLabel.text = noItemsText
            tableView.isHidden = true
        } else if data.isExpanded {
            itemDescriptionStackView.isHidden = true
            tableView.isHidden = false
        } else {
            itemDescriptionStackView.isHidden = false
            tableView.isHidden = true
            
            if section.recordType == .Documents {
                let names = section.recordItems
                    .compactMap { $0.document?.fileTitle }
                    .joined(separator: ", ")
                
                itemDescriptionLabel.text = String(format: L("card_items_description"), "\(section.recordItems.count)", names)
                
            } else {
                let names = section.recordItems
                    .map { $0.description }
                    .joined(separator: ", ")
                
                itemDescriptionLabel.text = String(format: L("card_items_description"), "\(section.recordItems.count)", names)
            }
        }
    }
}

extension DashboardProfileCell: NibInstanceable {
    static func nibName() -> String {
        return "DashboardProfileCell"
    }
}

//MARK: - Record TableView
class RecordTableView: UITableView {
    
    private var recordCellId = "RecordItemCellId"
    private var documentCellId = "DocumentCell"
    private var sectionHeaderViewId = "SectionHeaderViewId"
    
    private var dashboardSection = DashboardSection(recordItems: [], recordType: .Allergy)
    
    var didDeleteRecord: ((RecordDeleteItem) -> Void) = { _ in }
    var didDeleteDocument: ((Document) -> Void) = { _ in }
    var didEditDocument: ((Document) -> Void) = { _ in }
    var didSelectDocument: ((Document) -> Void) = { _ in }
    var didShareDocument: ((Document) -> Void) = { _ in }
    
    private var cellSizes = [AnyHashable: CGFloat]()
    private var sampleDocumentCell = DocumentCell.nibInstance()
    private lazy var sampleRecordCell = recordCell()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cornerRadius = 10
        
        isScrollEnabled = false
        
        dataSource = self
        delegate = self
        
        register(UINib(nibName: "DocumentTypeHeaderCell", bundle: nil), forHeaderFooterViewReuseIdentifier:  sectionHeaderViewId)
        register(UINib(nibName: "DocumentCell", bundle: nil), forCellReuseIdentifier: documentCellId)
    }
    
    override var intrinsicContentSize: CGSize {
        estimateSize
    }
    
    private var estimateSize = CGSize.zero
    
    override func reloadData() {
        super.reloadData()
        estimateSize = calculateContentSize()
        self.invalidateIntrinsicContentSize()
    }
    
    func reload(dashboardSection: DashboardSection) {
        self.dashboardSection = dashboardSection
        self.reloadData()
    }
    ///Delete
    func deleteRecordTapped(at indexPath: IndexPath) {
        let recordToDelete = dashboardSection.itemAtIndexPath(indexPath)
        let recordDeleteItem = RecordDeleteItem(type: dashboardSection.recordType, recordItem: recordToDelete)
        didDeleteRecord(recordDeleteItem)
    }
    ///Share
    func shareRecordTapped(at indexPath: IndexPath) {
        if let document = dashboardSection.itemAtIndexPath(indexPath).document {
            didShareDocument(document)
        }
    }
    func editDocumentTapped(at indexPath: IndexPath) {
        if let document = dashboardSection.itemAtIndexPath(indexPath).document {
            didEditDocument(document)
        }
    }
    func deleteDocumentTapped(at indexPath: IndexPath) {
        if let document = dashboardSection.itemAtIndexPath(indexPath).document {
            didDeleteDocument(document)
        }
    }
    
    private func calculateContentSize() -> CGSize {
        let sections = dashboardSection.numberOfSections()
        let headerCount = (0 ..< sections)
            .compactMap { dashboardSection.titleForSection($0) }
            .count
        
        let rows = (0 ..< sections).flatMap { section -> [IndexPath] in
            (0 ..< dashboardSection.numberOfItemsInSection(section)).map {
                IndexPath(item: $0, section: section)
            }
        }
        
        let rowHeight = rows.reduce(CGFloat(0)) { partialResult, indexPath in
            let recordItem = dashboardSection.itemAtIndexPath(indexPath)
            return partialResult + fittingHeight(recordItem: recordItem)
        }
        
        let totalHeight = CGFloat(headerCount) * 35 + rowHeight
        return CGSize(width: bounds.width, height: totalHeight)
    }
}

extension RecordTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let recordItem = dashboardSection.itemAtIndexPath(indexPath)
        return fittingHeight(recordItem: recordItem)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dashboardSection.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dashboardSection.numberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recordItem = dashboardSection.itemAtIndexPath(indexPath)
        if dashboardSection.recordType == .Documents {
            let cell = dequeueReusableCell(withIdentifier: documentCellId, for: indexPath) as! DocumentCell
            cell.fill(recordItem)
            return cell
        } else {
            let cell = dequeueReusableCell(withIdentifier: recordCellId) ?? recordCell()
            cell.textLabel?.text = recordItem.description
            cell.detailTextLabel?.text = recordItem.code
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = dashboardSection.titleForSection(section) else {
            return nil
        }
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderViewId) as! DocumentTypeHeaderCell
        headerCell.fill(title)
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        dashboardSection.titleForSection(section) != nil ? 35 : 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let document = dashboardSection.itemAtIndexPath(indexPath).document {
            didSelectDocument(document)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            completion(true)
            if self.dashboardSection.recordType == .Documents {
                self.deleteDocumentTapped(at: indexPath)
            } else {
                self.deleteRecordTapped(at: indexPath)
            }
        }
        
        deleteAction.image = UIImage(named: "delete")
        deleteAction.backgroundColor =  .red
        let shareAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completion) in
            completion(true)
            self?.shareRecordTapped(at: indexPath)
        }
        shareAction.image = UIImage(named: "share-document")
        shareAction.backgroundColor = .systemBlue
        
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completion) in
            completion(true)
            self?.editDocumentTapped(at: indexPath)
        }
        editAction.image = UIImage(named: "edit-document")
        editAction.backgroundColor = .gray
        var config = UISwipeActionsConfiguration(actions: [])
        if dashboardSection.recordType == .Documents {
            config = UISwipeActionsConfiguration(actions: [shareAction, editAction, deleteAction])
        } else {
            config = UISwipeActionsConfiguration(actions: [deleteAction])
        }
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    func configRecordCell(_ cell: UITableViewCell, recordItem: RecordItem) {
        cell.textLabel?.text = recordItem.description
        cell.detailTextLabel?.text = recordItem.code
    }
    
    private func recordCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: recordCellId)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        cell.textLabel?.textColor = .black
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = .white
        return cell
    }
    
    private func fittingHeight(recordItem: RecordItem) -> CGFloat {
        if let h = cellSizes[recordItem.hash] {
            return h
        }
        
        let cell: UITableViewCell
        if dashboardSection.recordType == .Documents {
            sampleDocumentCell.fill(recordItem)
            cell = sampleDocumentCell
        } else {
            configRecordCell(sampleRecordCell, recordItem: recordItem)
            cell = sampleRecordCell
        }
        
        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.width = bounds.width
        fittingSize = cell.systemLayoutSizeFitting(fittingSize,
                                                   withHorizontalFittingPriority: .required,
                                                   verticalFittingPriority: UILayoutPriority(rawValue: 1))
        
        cellSizes[recordItem.hash] = fittingSize.height
        
        return fittingSize.height
    }
}
