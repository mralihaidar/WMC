//
//  UIStoryboard.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 17/01/22.
//

import UIKit

protocol IdentifierType {
    associatedtype Identifier: RawRepresentable
}

extension UIStoryboard : IdentifierType {
    enum Identifier: String {
        case AuthenticationOptionViewController = "OPTION_VIEW_CONTROLLER"
    }
    
    func instantiateViewControllerWithIdentifier(identifier: Identifier) -> UIViewController {
        return self.instantiateViewController(withIdentifier: identifier.rawValue)
    }
}

enum StoryboardName: String {
    case appTour = "ApplicationTour"
    case register = "Register"
    case profile = "Profile"
    case dashboard = "Dashboard"
    case subscription = "Subscription"

    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T {
        let storyBoardId = (viewControllerClass as UIViewController.Type).storyboardId
        return instance.instantiateViewController(withIdentifier: storyBoardId) as! T
    }
}

extension UIViewController {
    class var storyboardId: String {
        return "\(self)"
    }
    
    static func instantiateFrom(storyboard: StoryboardName) -> Self {
        return storyboard.viewController(viewControllerClass: self)
    }
}
