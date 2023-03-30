//
//  FormControl.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 02/02/22.
//

import Foundation

@objc protocol FormControl {
    var key: String? { get }
    var text: String? { get }
    var validators: [Validator]? { get }
    var isValid: Bool { get }
    
    func clear()
}
