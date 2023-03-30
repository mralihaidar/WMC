//
//  Notification+Name.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 2/11/22.
//

import Foundation
extension Notification.Name {
    static let logoutUser = Notification.Name("User.Logout")
    static let reloadProfile = Notification.Name("Reload.User.Profile")
    static let reloadRecords = Notification.Name("Reload.Dashboard.Records")
}
