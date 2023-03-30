//
//  Document.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 1/31/22.
//

import UIKit

struct Document: JsonItemType {
    let fileId: Int
    let fileName: String
    let fileTitle: String
    let fileExtension: String
    let fileDescription: String?
    let fileCatagory: String?
    let dateCreated: String?
}
struct DocumentCategory: JsonItemType {
    let id: Int
    let categoryText: String
}
