//
//  PickerViewDataSourceDelegate.swift
//  WorldMedicalCard
//
//  Created by Abhishek Chatterjee on 09/02/22.
//

import UIKit

protocol FormPickerSelectable {
    var formDisplayableText: String { get }
}

extension UserProfile.Gender: FormPickerSelectable {
    var formDisplayableText: String {
        switch self {
        case .Male: return L("profile_gender_male")
        case .Female: return L("profile_gender_female")
        }
    }
}

extension Bool: FormPickerSelectable {
    var formDisplayableText: String {
        self ? L("common_yes") : L("common_no")
    }
}

extension Insurance.InsuranceType: FormPickerSelectable {
    var formDisplayableText: String {
        switch self {
        case .Travel: return L("profile_insurance_type_health")
        case .Health: return L("profile_insurance_type_travel")
        }
    }
}

enum PickerType: String {

    case gender = "gender"
    case choice = "choice"
    case insuranceType = "type"
    
    var objects: [FormPickerSelectable] {
        switch self {
        case .gender:
            return [UserProfile.Gender.Male, UserProfile.Gender.Female]
        case .choice:
            return [true, false]
        case .insuranceType:
            return [
                Insurance.InsuranceType.Health,
                Insurance.InsuranceType.Travel
            ]
        }
    }
}

class PickerViewDataSourceDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var collection: [FormPickerSelectable]
    var selectedValue: FormPickerSelectable?
    
    init(type: PickerType, selectedValue: FormPickerSelectable? = nil) {
        self.collection = type.objects
        self.selectedValue = selectedValue ?? collection.first
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return collection.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return collection[row].formDisplayableText
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = collection[row]
    }
}
