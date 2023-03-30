//
//  SubscriptionTableViewCell.swift
//  WorldMedicalCard
//
//  Created by Apphuset on 03/06/2022.
//

import UIKit

final class SubscriptionTableViewCell: UITableViewCell {

    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var managerLabel: UILabel!
    @IBOutlet var occupancyLabel: UILabel!
    @IBOutlet var expirationLabel: UILabel!
    @IBOutlet var typeIconImageView: UIImageView!
    @IBOutlet var typeRibbonImageView: UIImageView!

    static var expirationFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMyyyy", options: 0, locale: .current)
        return df
    }

    func fill(subscription: SubscriptionListItem, isOwner: Bool) {
        typeLabel.text = subscription.name
        managerLabel.text = subscription.subscriptionOwner ?? "-"
        occupancyLabel.text = "\(subscription.currentMembers) / \(subscription.totalMembers)"
        if let exp = subscription.expireOn {
            expirationLabel.text = Self.expirationFormatter.string(from: exp)
        } else {
            expirationLabel.text = "-"
        }

        typeIconImageView.image = UIImage(named: isOwner ? "subscription_owner" : "subscription_member")
        typeRibbonImageView.image = UIImage(named: isOwner ? "subscription_ribbon_owner" : "subscription_ribbon")
    }
}
