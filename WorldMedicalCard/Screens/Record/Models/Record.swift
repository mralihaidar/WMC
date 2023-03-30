//
//  Record.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 1/26/22.
//

import UIKit

struct RecordItem: JsonItemType {
    let code: String
    let description: String
    let document: Document?
}

struct RecordDeleteItem {
    let type: Dashboard.DashboadItemType
    let recordItem: RecordItem
}

struct JsonItemList<T: JsonItemType>: Codable {
    var items: [T]
    var total: Int
    var take: Int
}

protocol JsonItemType: Codable {
    
}

extension RecordItem {
    var hash: String {
        document?.fileId.description ?? code
    }
}
