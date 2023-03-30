//
//  SubscriptionMemberTableViewCell.swift
//  WorldMedicalCard
//
//  Created by Apphuset on 04/06/2022.
//

import UIKit

final class SubscriptionMemberTableViewCell: UITableViewCell {

    @IBOutlet var nameAbbreviationLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var loadingView: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        loadingView.hidesWhenStopped = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = 10
    }

    func fill(member: Subscription.Member, isLoading: Bool) {
        nameAbbreviationLabel.text = member.name.components(separatedBy: .whitespaces)
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
        nameLabel.text = member.name
        emailLabel.text = member.email

        isLoading ? loadingView.startAnimating() : loadingView.stopAnimating()
        contentView.alpha = isLoading ? 0.5 : 1.0
    }

}
