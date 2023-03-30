//
//  UIFont.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 26/01/22.
//

import UIKit

enum FontName: String {
    case proBold = "SFProDisplay-Bold"
    case proMedium = "SFProDisplay-Medium"
    case proRegular = "SFProDisplay-Regular"
    case proSemibold = "SFProDisplay-Semibold"
    case compactRegular = "SFCompactDisplay-Regular"
    case compactSemibold = "SFCompactDisplay-Semibold"
}

extension UIFont {
    class func applicationFonts(name: FontName, size: CGFloat) -> UIFont {
        if let font = UIFont(name: name.rawValue, size: size) {
            return font
        }
        return UIFont()
    }
}
