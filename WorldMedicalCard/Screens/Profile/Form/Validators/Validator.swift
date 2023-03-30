//
//  Validator.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 02/02/22.
//

import Foundation

@objc protocol Validator {
    func validate(_ text: String?) -> Bool
}
