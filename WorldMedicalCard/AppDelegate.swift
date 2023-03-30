//
//  AppDelegate.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 18/01/22.
//

import UIKit
import Lokalise
import Firebase
import GoogleSignIn
//import SPError
//import FirebaseCrashlytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(forName: .logoutUser, object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.logout()
        }
        ///Lokalise
        Lokalise.shared.setProjectID(Constants.LokaliseProjectID, token: Constants.LokaliseToken)
        Lokalise.shared.localizationType = Environment.lokaliseType == "release" ? .release : .prerelease

        FirebaseApp.configure()
//        configureSPError()
        isUserLoggedIn ? showDashboard() : showOnboarding()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        Lokalise.shared.checkForUpdates { (isUpdated, error) in
            if let error = error {
                print("😭 Lokalise update error \(error)")
            } else if isUpdated {
                print("Lokalise updated successfully 🎉!")
            } else {
                print("Lokalise is up-to-date. Nothing to do 🎉!")
            }
        }
    }
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        
        //Handle the URL that your application receives at the end of the authentication process.
        return GIDSignIn.sharedInstance.handle(url)
    }
}

//MARK: - Setup Entry
extension AppDelegate {
    func showDashboard() {
        let viewController = DashboardViewController.instantiateFrom(storyboard: .dashboard)
        let navigationController = CustomNavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    func showOnboarding() {
        let viewController = ApplicationTourViewController.instantiateFrom(storyboard: .appTour)
        let navigationController = CustomNavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    private var isUserLoggedIn: Bool {
        return UserDefaults.standard.value(forKey: Constants.UserDefaults_Key_UID) != nil
    }
    private func logout() {
        // Firebase + Auth
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults_Key_UID)
        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults_Key_DOB)
        MainAuthProvider.shared.cleanUp()
        showOnboarding()
    }
}
//MARK: -
extension AppDelegate {
//    func configureSPError() {
//        ErrorTracker.set(logger: Crashlytics.crashlytics())
//        ErrorTracker.register(tracker: AlamofireErrorTracker.shared)
//        ErrorTracker.register(tracker: CoreDataErrorTracker.shared)
//        ErrorTracker.startTracking()
//    }
}
//extension Crashlytics: ErrorLogger {
//    public func recordError(_ error: Swift.Error) {
//        Crashlytics.crashlytics().record(error: error)
//    }
//}
