//
//  FloatLabelTextField.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 30/01/22.
//

import UIKit

@IBDesignable class FloatLabelTextField: TextField {
    var enableMaterialPlaceHolder = true
    var lblPlaceHolder = UILabel()
    var placeholderFont = UIFont.applicationFonts(name: .proRegular, size: 16)
    var difference: CGFloat = 20.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize ()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize ()
    }
    
    func initialize() {
        clipsToBounds = false
        addTarget(self, action: #selector(FloatLabelTextField.textFieldDidChange), for: .editingChanged)
        font = UIFont.applicationFonts(name: .proRegular, size: 16)
        enableMaterialPlaceHolder(true)
    }
    
    @IBInspectable var placeHolderColor: UIColor? = UIColor.lightGray {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder! as String ,
                                                            attributes: [NSAttributedString.Key.foregroundColor: placeHolderColor!])
        }
    }
    
    override public var placeholder: String?  {
        willSet {
            let atts  = [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: placeholderFont]
            if let value = newValue {
                attributedPlaceholder = NSAttributedString(string: value, attributes: atts)
                enableMaterialPlaceHolder(enableMaterialPlaceHolder)
                animatePlaceholderText()
            }
        }
    }
    
    override public var attributedText: NSAttributedString?  {
        willSet {
            if (placeholder != nil) && (text != "") {
                placeholderText(placeholder!)
            }
        }
    }
    
    @objc func textFieldDidChange() {
        if let value = text, (value.count) > 0, enableMaterialPlaceHolder {
            lblPlaceHolder.alpha = 1
            attributedPlaceholder = nil
            lblPlaceHolder.textColor = self.placeHolderColor
            lblPlaceHolder.frame.origin.x = 12
            self.lblPlaceHolder.font = UIFont.applicationFonts(name: .proRegular, size: 12)
        }
        animatePlaceholderText()
    }
    
    private func animatePlaceholderText() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {() -> Void in
            if (self.text == nil) || (self.text?.count)! <= 0 {
                self.lblPlaceHolder.font = self.font
                self.lblPlaceHolder.frame = CGRect(x: self.lblPlaceHolder.frame.origin.x, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            }
            else {
                //If Text is not empty show floating label always
                self.lblPlaceHolder.alpha = 1
                self.attributedPlaceholder = nil
                self.lblPlaceHolder.textColor = self.placeHolderColor
                self.lblPlaceHolder.frame.origin.x = 12
                self.lblPlaceHolder.font = UIFont.applicationFonts(name: .proRegular, size: 12)
                
                
                self.lblPlaceHolder.frame = CGRect(x: self.lblPlaceHolder.frame.origin.x, y: -self.difference, width: self.frame.size.width, height: self.frame.size.height)
            }
        }, completion: {(finished: Bool) -> Void in
        })
    }
    
    func enableMaterialPlaceHolder(_ flag: Bool) {
        enableMaterialPlaceHolder = flag
        lblPlaceHolder = UILabel()
        lblPlaceHolder.frame = CGRect(x: 12, y: 0, width: 0, height: self.frame.size.height)
        lblPlaceHolder.font = UIFont.applicationFonts(name: .proRegular, size: 12)
        lblPlaceHolder.alpha = 0
        lblPlaceHolder.clipsToBounds = true
        addSubview(lblPlaceHolder)
        lblPlaceHolder.attributedText = self.attributedPlaceholder
    }
    
    func placeholderText(_ placeholder: String) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                         NSAttributedString.Key.font: UIFont.labelFontSize]
        )
        enableMaterialPlaceHolder(enableMaterialPlaceHolder)
    }
    
    @discardableResult
    override public func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    override public func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    override var text: String? {
        didSet {
            animatePlaceholderText()
        }
    }
}
