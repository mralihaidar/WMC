//
//  Date.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 1/25/22.
//

import Foundation

extension Date {
    var timeOfTheDay: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
            case 6..<12:
                return L("dashboard_screen_title_morning")
            case 12..<17:
                return L("screen_title_good_afternoon")
            case 17..<22:
                return L("dashboard_screen_title_evening")
            default:
                return L("dashboard_screen_title_night")
        }
    }
    func string(format: String? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format ?? "yyyy" //2021-10-01T00:00:00Z
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: self)
    }
}
extension TimeInterval {
    static let oneHour: TimeInterval = 3600 //seconds
}
