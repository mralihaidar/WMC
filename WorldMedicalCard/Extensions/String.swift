//
//  String.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 1/20/22.
//

import Lokalise

/// Localize text
func L(_ key: String) -> String {
    return Lokalise.shared.localizedString(forKey: key, value: nil, table: nil)
}

extension Optional where Wrapped == String {
    var isEmptyValue: Bool {
        return (self?.isEmpty ?? false) || (self == nil)
    }
}
