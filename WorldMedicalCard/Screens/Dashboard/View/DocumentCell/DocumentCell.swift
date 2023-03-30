//
//  DocumentCell.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/4/22.
//

import UIKit

class DocumentCell: UITableViewCell {

    @IBOutlet weak var documentDescriptionLabel: UILabel!
    @IBOutlet weak var documentTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        documentTitleLabel.numberOfLines = 0
    }
    func fill(_ item: RecordItem) {
        guard let document = item.document else {
            return
        }
        documentTitleLabel.text = document.fileTitle
        documentDescriptionLabel.isHidden = document.fileDescription == nil
        documentDescriptionLabel.text = document.fileDescription
    }
}
extension DocumentCell: NibInstanceable {
    static func nibName() -> String {
        return "DocumentCell"
    }
}
