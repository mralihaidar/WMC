//
//  DashboardTableView.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 1/24/22.
//

import UIKit

class DashboardTableView: UITableView {

    ///Privates
    private var dashboard = Dashboard()

    ///Publics
    var didAdd: ((Dashboard.DashboadItemType) -> Void) = { _ in }
    var didShare: ((Dashboard.DashboadItemType) -> Void) = { _ in }
    var didTranslateRecord: ((Dashboard.DashboadItemType) -> Void) = { _ in }
    var didDeleteRecord: ((RecordDeleteItem) -> Void) = { _ in }
    
    ///Document
    var didDeleteDocument: ((Document) -> Void) = { _ in }
    var didEditDocument: ((Document) -> Void) = { _ in }
    var didSelectDocument: ((Document) -> Void) = { _ in }
    var didShareDocument: ((Document) -> Void) = { _ in }

    private var cellId = "CellId"
    private var sectionHeaderViewId = "SectionHeaderViewId"
    private var sectionFooterViewId = "SectionFooterViewId"

    private var cellHeights = [String: CGFloat]()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        register(UINib(nibName: "DashboardProfileCell", bundle: nil), forCellReuseIdentifier: cellId)
        register(UINib(nibName: "DashboardHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: sectionHeaderViewId)
        register(UINib(nibName: "DashboardFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: sectionFooterViewId)
        
        delegate = self
        dataSource = self
    }

    func reload(alergies: [RecordItem], medications: [RecordItem], diagnosis: [RecordItem],
                vaccines: [RecordItem], documents: [RecordItem]) {
        
        dashboard.reload(type: .Allergy, items: alergies)
        dashboard.reload(type: .Medication, items: medications)
        dashboard.reload(type: .Diagnosis, items: diagnosis)
        dashboard.reload(type: .Vaccine, items: vaccines)
        dashboard.reload(type: .Documents, items: documents)
        
        reloadData()
    }
    
    func deleteRecordItem(_ item: RecordDeleteItem) {
        if let section = dashboard.removeItem(type: item.type, item: item.recordItem) {
            reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }
}
//MARK: - TableView Delegate methods
extension DashboardTableView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        dashboard.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dashboard.numberOfItemsInSection(section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderViewId) as! DashboardHeaderView
        headerCell.fill(data: dashboard.sectionDisplayableForSection(section))

        headerCell.didPressHeader = { recordType in
            self.dashboard.toggleExpansion(type: recordType)
            self.reloadSections(IndexSet(integer: section), with: .automatic)
//            UIView.performWithoutAnimation {
//                self.reloadData()
//                self.reloadSections(IndexSet(sections), with: .none)
//            }
        }
        return headerCell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionData = dashboard.sectionDisplayableForSection(section)
        guard sectionData.isExpanded else {
            return nil
        }
        
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionFooterViewId) as! DashboardFooterView
        
        footerView.fill(section: sectionData.section)

        footerView.didAdd = { [weak self] recordType in
            self?.didAdd(recordType)
        }
        footerView.didShare = { [weak self] recordType in
            self?.didShare(recordType)
        }
        footerView.didTranslate = { [weak self] recordType in
            self?.didTranslateRecord(recordType)
        }
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        52
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        dashboard.shouldShowFooterInSection(section) ? 50 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! DashboardProfileCell

        let nestedActionView = cell.tableView!
        nestedActionView.didDeleteRecord = { recordDeleteItem in
            self.didDeleteRecord(recordDeleteItem)
        }
        nestedActionView.didDeleteDocument = { document in
            self.didDeleteDocument(document)
        }
        nestedActionView.didEditDocument = { document in
            self.didEditDocument(document)
        }
        nestedActionView.didSelectDocument = { document in
            self.didSelectDocument(document)
        }
        nestedActionView.didShareDocument = { document in
            self.didShareDocument(document)
        }
        
        cell.fill(sectionDisplayable: dashboard.sectionDisplayableForSection(indexPath.section))
        
        return cell
    }
}
