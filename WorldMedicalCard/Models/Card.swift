//
//  Card.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/23/22.
//

import Foundation

struct Card: Codable {
    let type: String
    let title: String
    let status: Bool
    let detail: String
    let instance: String
}
