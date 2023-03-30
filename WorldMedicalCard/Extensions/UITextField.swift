//
//  UITextField.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 19/01/22.
//

import UIKit

@IBDesignable class TextField: UITextField {
    
    @IBInspectable var insetX: CGFloat = 12
    @IBInspectable var insetY: CGFloat = 0
    
    @IBInspectable override var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    func setRightView(image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        iconView.contentMode = .center
        iconView.image = image
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(iconView)
        rightView = iconContainerView
        rightViewMode = .always
    }
}

@IBDesignable class TextView: UITextView {
    
    @IBInspectable var insetX: CGFloat = 12
    @IBInspectable var insetY: CGFloat = 0
    
    @IBInspectable override var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
}
