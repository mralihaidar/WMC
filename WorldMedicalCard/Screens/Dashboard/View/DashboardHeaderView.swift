//
//  DashboardHeaderView.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 2/14/22.
//

import UIKit

class DashboardHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var sectionHeaderButton: UIButton!

    private var recordType: Dashboard.DashboadItemType?
    var didPressHeader: ((Dashboard.DashboadItemType) -> Void)?
    
    func fill(data: Dashboard.SectionDisplayable) {
        let item = data.section
        self.recordType = item.recordType

        switch item.recordType {
        case .Allergy:
            itemTitleLabel.text = L("allergies_card_title")
            itemImageView.image = UIImage(named: item.isEmpty ? "Allergies" : "allergies_fill")
        case .Medication:
            itemTitleLabel.text = L("medicine_card_title")
            itemImageView.image = UIImage(named: item.isEmpty ? "medicine" : "medicine_fill")
        case .Diagnosis:
            itemTitleLabel.text = L("diagnoses_card_title")
            itemImageView.image = UIImage(named: item.isEmpty ? "Diagnoses" : "diagnosis_fill")
        case .Vaccine:
            itemTitleLabel.text = L("vaccines_card_title")
            itemImageView.image = UIImage(named: item.isEmpty ? "Vaccines" : "vaccine_fill")
        case .Documents:
            itemTitleLabel.text = L("documents_card_title")
            itemImageView.image = UIImage(named: item.isEmpty ? "Documents" : "documents_fill")
        }
        
        arrowImageView.transform = CGAffineTransform(rotationAngle: data.isExpanded ? 0 : .pi)
        
    }
    
    @IBAction func sectionHeaderTapped(_ sender: UIButton) {
        guard let recordType = recordType else { return }
        didPressHeader?(recordType)
    }
}
