//
//  Encodable.swift
//  WorldMedicalCard
//
//  Created by Abhishek Chatterjee on 10/02/22.
//

import UIKit

extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let josnData = try JSONSerialization.jsonObject(with: data)
        return josnData as? [String : Any]
    }
}

