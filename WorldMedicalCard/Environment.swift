//
//  Environment.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 2/25/22.
//

import Foundation

struct Environment {
    
    static var userDefined: [String: Any]  {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        
        return dict["UserDefined"] as! [String: Any]
    }
    
    private static func get(_ key: String) -> String {
        guard let value = userDefined[key] as? String else {
            fatalError("\(key) is missing")
        }
        return value
    }
}
extension Environment {
    static var apiBaseUrl = get("ApiBaseURL")
    static var lokaliseType = get("lokaliseType")
    
    static func log() {
        print("Api Base Url: \(apiBaseUrl)")
    }
    
    static var subscriptionUrl = URL(string: "https://www.worldmedicalcard.org/#subscriptions")!
}

