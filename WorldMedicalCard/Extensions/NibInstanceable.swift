//
//  NibInstanceable.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 2/14/22.
//

import UIKit

protocol NibInstanceable {
    static func nibName() -> String
}

extension NibInstanceable where Self: UIView {

    /**
     Create and UIView and subclass instance from a nib in the Main bundle.

     Force un-wrap is used as early exception in case can not find a suitable instance.

     - Returns: Instance from nib resource.
     */
    static func nibInstance() -> Self {
        return Bundle.main.loadNibNamed(Self.nibName(), owner: nil, options: nil)?.first as! Self
    }
}

extension NibInstanceable {
    /**
     Create a UINib instance from nib name and bundle

     - Parameter bundle: the bundle contains nib

     - Returns: Instance of UINib
     */
    static func nib(inBundle bundle: Bundle? = nil) -> UINib {
        return UINib(nibName: nibName(), bundle: bundle)
    }
}
