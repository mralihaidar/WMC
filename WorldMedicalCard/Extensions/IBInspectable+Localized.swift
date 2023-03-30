//
//  IBInspectable+Localized.swift
//  WorldMedicalCard
//
//  Created by Apphuset on 04/06/2022.
//

import UIKit

extension UILabel {
    @IBInspectable var localizedKey: String? {
        get { text }
        set {
            if let key = newValue {
                text = L(key)
            } else {
                text = nil
            }
        }
    }
}

extension UIButton {
    @IBInspectable var localizedKey: String? {
        get { title(for: .normal) }
        set {
            if let key = newValue {
                setTitle(L(key), for: .normal)
            } else {
                setTitle(nil, for: .normal)
            }
        }
    }
}
