//
//  FormTextField.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 02/02/22.
//

import UIKit

@IBDesignable class FormTextField: FloatLabelTextField {
    
    // MARK: - Inspectables
    @IBInspectable var key: String?
    
    // MARK: - Outlets
    @IBOutlet var validators: [Validator]?
    
    fileprivate var isDateField = false
    fileprivate var pickerType: PickerType?
    
    private lazy var pickerView = UIPickerView()
    private lazy var screenWidth = UIScreen.main.bounds.width

    private var datasource: PickerViewDataSourceDelegate?
    
    private var isOptional = true
    private var _formValue: Any?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
    }
    
    override func textFieldDidChange() {
        super.textFieldDidChange()
        
        if isValid {
            clearInvalidInput()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        return dateformatter
    }
}

extension FormTextField: FormControl {
    var formValue: Any? {
        _formValue
    }
    
    func setFormValue(_ value: Any?) {
        _formValue = value
        
        if isDate, let date = value as? Date {
            text = dateFormatter.string(from: date)
            UserDefaults.standard.set(date.string(format: "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'"),
                                      forKey: Constants.UserDefaults_Key_DOB)
        } else if let v = value as? Bool {
            text = v.formDisplayableText
        } else if let v = value as? FormPickerSelectable {
            text = v.formDisplayableText
        } else if let v = value {
            text = "\(v)"
        } else {
            text = nil
        }
        
        if isValid {
            clearInvalidInput()
        }
    }
    
    var isDate: Bool {
        get {
            return isDateField
        }
        set {
            isDateField = newValue
            setInputViewDatePicker()
        }
    }
    
    var dropdownType: String? {
        get {
            return pickerType?.rawValue
        }
        set {
            pickerType = PickerType(rawValue: newValue!)!
            setInputViewPicker()
        }
    }
    
    @objc func tapDone() {
        if let datePicker = inputView as? UIDatePicker {
            setFormValue(datePicker.date)
        } else if let datePicker = inputView as? UIPickerView,
                  let delegate = datePicker.delegate as? PickerViewDataSourceDelegate {
            setFormValue(delegate.selectedValue)
        }
        resignFirstResponder()
    }
    
    var isValid: Bool {
        isOptional || !text.isEmptyValue
    }
    
    func canEdit(_ flag: Bool) {
        isUserInteractionEnabled = flag
    }
    
    func clear() {
        text = nil
    }
    
    func setInputViewDatePicker() {
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        datePicker.datePickerMode = .date
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        inputView = datePicker
        inputAccessoryView = pickerViewToolbar()
    }
    
    func setInputViewPicker() {
        datasource = PickerViewDataSourceDelegate(type: pickerType!, selectedValue: (formValue as? FormPickerSelectable))
        pickerView.dataSource = datasource
        pickerView.delegate = datasource
        inputView = pickerView
        inputAccessoryView = pickerViewToolbar()
    }
    
    @objc func tapCancel() {
        resignFirstResponder()
    }
    
    private func pickerViewToolbar() -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: L("cancel_button_title"), style: .plain, target: nil, action: #selector(tapCancel))
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(tapDone))
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        return toolBar
    }
    
    /// mark the input field is optional/required
    func setOptionalInput(isOptional: Bool) {
        self.isOptional = isOptional
    }

    func showInvalidInput() {
        borderColor = UIColor.systemRed
        borderWidth = 1
    }
    
    func clearInvalidInput() {
        borderColor = .clear
        borderWidth = 0
    }
}

extension FormTextField: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.superview?.endEditing(true)
        return false
    }
}



