//
//  PickerView.swift
//  Watt
//
//  Created by Adeel-dev on 9/1/21.
//

import UIKit

class PickerView: UIPickerView {
    
    enum DataSourceType {
        case documentCategory
        case language
    }
    
    ///privates
    private var categories = [DocumentCategory]()
    private var languages = [Language]()
    private var dataSourceType: DataSourceType = .documentCategory
    
    ///publics
    var didSelect: ((DocumentCategory) -> Void)?
    var didSelectLanguage: ((Language) -> Void)?
    
    func reload(_ categories: [DocumentCategory], dataSourceType: DataSourceType, languages: [Language]) {
        self.categories = categories
        self.languages = languages
        self.dataSourceType = dataSourceType
        delegate = self
        dataSource = self

        reloadAllComponents()
    }
    func title(at row: Int) -> String? {
        return dataSourceType == .documentCategory ? categories[row].categoryText : languages[row].name
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func selectedCategory() -> DocumentCategory? {
        let row = selectedRow(inComponent: 0)
        guard dataSourceType == .documentCategory, !categories.isEmpty, row >= 0 else {
            return nil
        }

        return categories[row]
    }
}
//MARK: - UIPicker View
extension PickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSourceType == .documentCategory ? categories.count : languages.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dataSourceType == .documentCategory ? didSelect?(categories[row]) : didSelectLanguage?(languages[row])
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        let value = title(at: row)
        label.attributedText = NSAttributedString(string: value ?? "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)])
        label.textColor = #colorLiteral(red: 0.1490196078, green: 0.1960784314, blue: 0.2196078431, alpha: 1)
        label.textAlignment = .center
        return label
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return title(at: row)
    }
}
