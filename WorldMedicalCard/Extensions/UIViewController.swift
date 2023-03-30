//
//  UIViewController.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 24/01/22.
//

import UIKit
import Alamofire

typealias okCompletion = (() -> Void)?

extension UIViewController {
    @discardableResult
    func alert(title: String? = nil, message: String? = nil, ok: okCompletion = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L("ok_button_title"), style: .cancel, handler: { _ in
            ok?()
        }))
        present(alert, animated: true, completion: nil)
        return alert
    }
    func showMessagePrompt(_ message: String, title: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: L("ok_button_title"), style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
    }
    
    func showTextInputPrompt(withMessage message: String,
                             completionBlock: @escaping ((Bool, String?) -> Void)) {
        let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: L("cancel_button_title"), style: .cancel) { _ in
            completionBlock(false, nil)
        }
        weak var weakPrompt = prompt
        let okAction = UIAlertAction(title: L("ok_button_title"), style: .default) { _ in
            guard let text = weakPrompt?.textFields?.first?.text else { return }
            completionBlock(true, text)
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(cancelAction)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    public func displayError(_ error: Error?, from function: StaticString = #function) {
        guard let error = error else { return }
        print("ⓧ Error in \(function): \(error.localizedDescription)")
        let message = "\(error.localizedDescription)\n\n Ocurred in \(function)"
        let errorAlertController = UIAlertController(
            title: L("error_no_data_found"),
            message: message,
            preferredStyle: .alert
        )
        errorAlertController.addAction(UIAlertAction(title: L("ok_button_title"), style: .default))
        present(errorAlertController, animated: true, completion: nil)
    }
}
//MARK: - RightBarButton Item & Appearance
extension UIViewController {
    func setupRightButtonItem(with title: String? = nil, image: UIImage? = nil, action: @escaping () -> Void) {
        let moreOptions = UIButton(type: .custom) //also loading indicator
        if let image = image {
            moreOptions.setImage(image, for: .normal)
            moreOptions.frame = CGRect(x: 0.0, y: 0.0, width: 24, height: 24)
        } else if let title = title {
            moreOptions.setTitle(title, for: .normal)
            moreOptions.setTitleColor(UIColor.systemBlue, for: .normal)
            moreOptions.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.5), for: .disabled)
            moreOptions.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
        }
        moreOptions.addAction(for: .touchUpInside) { (button) in
            action()
        }
        let rightBarItem = UIBarButtonItem(customView: moreOptions)
        navigationItem.rightBarButtonItem = rightBarItem
    }
    func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        appearance.shadowColor = nil
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
}
extension UIControl {
    
    public typealias UIControlTargetClosure = (UIControl) -> ()
    
    private class UIControlClosureWrapper: NSObject {
        let closure: UIControlTargetClosure
        init(_ closure: @escaping UIControlTargetClosure) {
            self.closure = closure
        }
    }
    
    private struct AssociatedKeys {
        static var targetClosure = "target_closure_key"
    }
    
    private var targetClosure: UIControlTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? UIControlClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, UIControlClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
    
    public func addAction(for event: UIControl.Event, closure: @escaping UIControlTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIControl.closureAction), for: event)
    }
}

class CustomNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        let attributes = [NSAttributedString.Key.font: UIFont.applicationFonts(name: .proMedium, size: 24)]
        UINavigationBar.appearance().titleTextAttributes = attributes
    }
}

extension CustomNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController.navigationItemBackButtonTextIsHidden {
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            viewController.navigationItem.backBarButtonItem?.tintColor = .black
        }
    }
}

extension UIViewController {
    @objc var navigationItemBackButtonTextIsHidden: Bool { return false }
}
