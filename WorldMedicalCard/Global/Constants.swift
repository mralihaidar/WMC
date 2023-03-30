//
//  Constants.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 1/20/22.
//

import Foundation

struct Constants {
    static let LokaliseToken = "fa0a369ecc613c08a8e899d7e0012ead718018b3"
    static let LokaliseProjectID = "389040506182907b165705.65765807"
    static let token = "JWTToken"
    static let UserDefaults_Key_UID = "useruid"
    static let UserDefaults_Key_DOB = "user.date.of.birth"
    
    static var currentLanguage: String {
        return Locale.current.regionCode ?? Locale.current.languageCode ?? ""
    }
}

