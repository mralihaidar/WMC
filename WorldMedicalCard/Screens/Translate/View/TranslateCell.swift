//
//  TranslateCell.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/30/22.
//

import UIKit

class TranslateCell: UITableViewCell {

    @IBOutlet weak var primaryTitleLabel: UILabel!
    @IBOutlet weak var secondaryTitleLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func fill(_ item: TableDataSourceModel) {
        primaryTitleLabel.text = item.primaryLanguage
        secondaryTitleLabel.text = item.secondaryLanguage
        codeLabel.text = item.code
    }
}
extension TranslateCell: NibInstanceable {
    static func nibName() -> String {
        return "TranslateCell"
    }
}
