//
//  Subscription.swift
//  WorldMedicalCard
//
//  Created by Apphuset on 04/06/2022.
//

import Foundation

struct SubscriptionListItem: Decodable, Hashable {
    let id: Int
    let name: String?
    let teamName: String?
    let subscriptionOwner: String?
    let totalMembers: Int
    let currentMembers: Int
    let expireOn: Date?

    static func == (lhs: SubscriptionListItem, rhs: SubscriptionListItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Subscription: Decodable {

    struct Member: Decodable {
        let id: Int
        let name: String
        let email: String
    }

    let id: Int
    let name: String?
    let teamName: String?
    let subscriptionOwner: String?
    let totalMembers: Int
    var currentMembers: Int
    let expireOn: Date?
    let number: String?
    let paymentMethod: String?
    let paymentMethodTitle: String?
    var members: [Member]?
}

extension Subscription {
    var listItem: SubscriptionListItem {
        SubscriptionListItem(id: id, name: name, teamName: teamName,
                             subscriptionOwner: subscriptionOwner, totalMembers: totalMembers,
                             currentMembers: currentMembers, expireOn: expireOn)
    }
}
