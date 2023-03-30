//
//  FormControl.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 02/02/22.
//

import Foundation

@objc protocol FormControl {
    var key: String? { get }
    var text: String? { get set }
    var placeholder: String? { get set }
    var validators: [Validator]? { get }
    var isValid: Bool { get }
    var isDate: Bool { get set }
    var dropdownType: String? { get set }

    func clear()
    func canEdit(_ flag: Bool)
    
    /// mark the input field is optional/required
    func setOptionalInput(isOptional: Bool)
    func showInvalidInput()
    func clearInvalidInput()
    
    /// Return the value the form is presenting
    /// If the date from, return Date.
    /// Else if the dropdown picker form, return picker value (anyhashble)
    /// Else, return the displayable text.
    var formValue: Any? { get }
    func setFormValue(_ value: Any?)
}
