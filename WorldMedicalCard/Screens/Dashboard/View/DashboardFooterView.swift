//
//  DashboardFooterView.swift
//  WorldMedicalCard
//
//  Created by Apphuset on 28/06/2022.
//

import UIKit

final class DashboardFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var translateView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        shareButton.setTitle(L("button_share"), for: .normal)
        addButton.setTitle(L("button_add"), for: .normal)
        translateButton.setTitle(L("button_translate"), for: .normal)
    }
    
    var didAdd: (Dashboard.DashboadItemType) -> Void = { _ in }
    var didShare: (Dashboard.DashboadItemType) -> Void = { _ in }
    var didTranslate: (Dashboard.DashboadItemType) -> Void = { _ in }

    private var section: DashboardSection?

    func fill(section: DashboardSection) {
        self.section = section

        shareView.isHidden = section.recordType == .Documents
        translateView.isHidden = section.recordType == .Documents
    }

    //MARK: - IBActions
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let section = section else { return }
        didAdd(section.recordType)
    }
    @IBAction func translateButtonTapped(_ sender: Any) {
        guard let section = section else { return }
        didTranslate(section.recordType)
    }
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let section = section else { return }
        didShare(section.recordType)
    }
}
