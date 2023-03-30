//
//  DocumentTypeHeaderCell.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/4/22.
//

import UIKit

class DocumentTypeHeaderCell: UITableViewHeaderFooterView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func fill(_ documentType: String) {
        titleLabel.text = documentType
    }
}
