//
//  Dashboard.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 1/24/22.
//

import UIKit

class Dashboard: NSObject {
    
    enum DashboadItemType: String, Codable {
        case Allergy
        case Medication
        case Diagnosis
        case Vaccine
        case Documents
    }
    
    private var dashboardSections = [DashboardSection]()
    private var expandedSectionTypes: [DashboadItemType] = [
        .Allergy, .Medication, .Diagnosis, .Vaccine, .Documents
    ]
    
    override init() {
        super.init()
        dashboardSections = [
            DashboardSection(recordItems: [], recordType: .Allergy),
            DashboardSection(recordItems: [], recordType: .Medication),
            DashboardSection(recordItems: [], recordType: .Diagnosis),
            DashboardSection(recordItems: [], recordType: .Vaccine),
            DashboardSection(recordItems: [], recordType: .Documents)
        ]
    }
    
    func reload(type: DashboadItemType, items: [RecordItem]) {
        guard let idx = dashboardSections.firstIndex(where: { $0.recordType == type }) else {
            return
        }
        dashboardSections[idx] = DashboardSection(recordItems: items, recordType: type)
    }
    
    /// remove item and return section of removal
    func removeItem(type: DashboadItemType, item: RecordItem) -> Int? {
        
        guard let idx = dashboardSections.firstIndex(where: { $0.recordType == type }) else { return nil }
        
        let section = dashboardSections[idx]
        let items = section.recordItems.filter { $0.hash != item.hash }
        
        reload(type: type, items: items)
        
        return idx
    }
    
    /// toggle expansion for a type and return section indices
    func toggleExpansion(type: DashboadItemType) {
        if let idx = expandedSectionTypes.firstIndex(of: type) {
            self.expandedSectionTypes.remove(at: idx)
        } else {
            self.expandedSectionTypes.append(type)
        }
    }
    
    func numberOfSections() -> Int {
        dashboardSections.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        1
    }
    
    // FIXME: move to new place for view model
    struct SectionDisplayable {
        let section: DashboardSection
        let isExpanded: Bool
    }
    
    func sectionDisplayableForSection(_ section: Int) -> SectionDisplayable {
        let dashboardSection = dashboardSections[section]
        return SectionDisplayable(section: dashboardSection,
                                  isExpanded: expandedSectionTypes.contains(dashboardSection.recordType))
    }
    
    func shouldShowFooterInSection(_ section: Int) -> Bool {
        let section = dashboardSections[section]
        return expandedSectionTypes.contains(section.recordType)
    }
}


struct DashboardSection {

    struct Category {
        let title: String?
        let recordItems: [RecordItem]
    }
    
    let recordItems: [RecordItem]
    let recordType: Dashboard.DashboadItemType
    let categories: [Category]
    
    var isEmpty: Bool {
        recordItems.isEmpty
    }
    
    init(recordItems: [RecordItem], recordType: Dashboard.DashboadItemType) {
        self.recordItems = recordItems
        self.recordType = recordType
        
        if recordType == .Documents {
            
            let sortedDocumentTuples = Dictionary(grouping: recordItems) { $0.document?.fileCatagory }
                .compactMap { element -> (key: String, value: [RecordItem])? in
                    guard let k = element.key else { return nil }
                    return (key: k, value: element.value)
                }
                .sorted { $0.key < $1.key }
            
            let documentSections = sortedDocumentTuples.map {
                Category(title: $0.key, recordItems: $0.value)
            }
            
            self.categories = documentSections
            
        } else {
            self.categories = [Category(title: nil, recordItems: recordItems)]
        }
    }
    
    func numberOfSections() -> Int {
        categories.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        categories[section].recordItems.count
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> RecordItem {
        categories[indexPath.section].recordItems[indexPath.row]
    }
    
    func titleForSection(_ section: Int) -> String? {
        categories[section].title
    }
}

//extension DashboardSection {
//    func save() {
//        do {
//            let encoder = JSONEncoder()
//            let section = DashboardSection(recordItems: self.recordItems, recordType: self.recordType, isExpanded: self.isExpanded)
//            let data = try encoder.encode(section)
//            UserDefaults.standard.set(data, forKey: self.recordType.rawValue)
//        } catch {
//            print("ERROR")
//        }
//    }
//    func load(_ type: Dashboard.DashboadItemType) -> DashboardSection {
//        if let data = UserDefaults.standard.data(forKey: type.rawValue) {
//            do {
//                let decoder = JSONDecoder()
//                return try decoder.decode(DashboardSection.self, from: data)
//            } catch {
//                print("ERROR")
//            }
//        }
//        return DashboardSection(recordItems: [], recordType: self.recordType, isExpanded: self.isExpanded)
//    }
//    func delete(_ type: Dashboard.DashboadItemType) {
//        UserDefaults.standard.set(nil, forKey: type.rawValue)
//    }
//}
