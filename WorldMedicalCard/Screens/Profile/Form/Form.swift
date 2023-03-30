//
//  Form.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 02/02/22.
//

import Foundation

class Form: NSObject {
    
    // MARK: - Outlets
    
    @IBOutlet var controls: [FormControl]?
    
    // MARK: - Properties
    
    var isValid: Bool {
        return controls?.reduce(true) { result, next in
            result && next.isValid
        } ?? true
    }
    
    // MARK: - Subscripts
    
    subscript(_ key: String) -> String? {
        return value(for: key)
    }
    
    // MARK: - Methods
    
    func value(for key: String) -> String? {
        return controls?.first(where: { $0.key == key })?.text ?? nil
    }
    
    func formValue(key: String) -> Any? {
        control(for: key)?.formValue
    }
    
    func setFormValue(_ value: Any?, formKey: String) {
        control(for: formKey)?.setFormValue(value)
    }
    
    func setPlaceholder(_ key: String, _ text: String) {
       controls?.first(where: { $0.key == key})?.placeholder = text
    }
    
    func control(for key: String) -> FormControl? {
        return controls?.first(where: { $0.key == key})
    }
    
    func canEdit(_ flag: Bool) {
        controls?.forEach { ($0 as? FormTextField)?.isUserInteractionEnabled = flag }
    }
    
    func clear() {
        controls?.forEach { $0.clear() }
    }
    
    func setOptionalInput(key: String, isOptional: Bool) {
        control(for: key)?.setOptionalInput(isOptional: isOptional)
    }
    
    func showInputValidation() {
        controls?.forEach {
            $0.isValid ? $0.clearInvalidInput() : $0.showInvalidInput()
        }
    }
}

