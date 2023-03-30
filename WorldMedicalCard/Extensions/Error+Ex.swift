//
//  Error+Ex.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/3/22.
//

import Foundation

extension NSError {
    static let unknown = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey : L("error_message")])
    
    static func errorFromAPI(apiError: DefaultApiError) -> NSError {
        let message = apiError.message ?? L("error_message")
        return NSError(domain: message, code: apiError.errorCode ?? 0, userInfo: [NSLocalizedDescriptionKey : message])
    }
}

