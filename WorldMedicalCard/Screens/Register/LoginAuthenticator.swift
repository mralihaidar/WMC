//
//  LoginAuthenticator.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 24/01/22.
//

import Foundation
import AuthenticationServices
import Firebase
import GoogleSignIn

protocol LoginAuthenticator {
    var delegate: ASAuthorizationControllerDelegate? { get set }
    
    func sendAppleSignInRequest()
    func handleMultiFactorAuthentication(error: NSError)
    func sendGoogleSignInRequest(completion: @escaping(AuthDataResult?, NSError?) -> Void)
    func signInGoogleUser(with email: String, password: String, completion: @escaping(AuthDataResult?, NSError?) -> Void)
    func sendAppleSignInRequest(with token: String, completion: @escaping(AuthDataResult?, NSError?) -> Void)
}

extension LoginAuthenticator where Self: UIViewController {
    
    private func getAuthCredential(completion: @escaping(FirebaseAuth.AuthCredential) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
                        
            completion(credential)
        }
    }
    
    func sendAppleSignInRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = delegate
        authorizationController.performRequests()
    }
    
    func sendGoogleSignInRequest(completion: @escaping(AuthDataResult?, NSError?) -> Void) {
        getAuthCredential { credential in
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error as NSError? {
                    completion(nil, error)
                }
                self.save(user: result?.user, completion: {
                    completion(result, nil)
                })
                completion(result, nil)
            }
        }
    }
    
    func createGoogleUser(with email: String, password: String, completion: @escaping(AuthDataResult?, NSError?) -> Void) {
        Auth.auth().createUser(
            withEmail: email,
            password: password) { result, error in
                if let error = error as NSError? {
                    completion(nil, error)
                }
                self.save(user: result?.user, completion: {
                    completion(result, nil)
                })
            }
    }
    
    func signInGoogleUser(with email: String, password: String, completion: @escaping(AuthDataResult?, NSError?) -> Void) {
        Auth.auth().signIn(
            withEmail: email,
            password: password) { result, error in
                if let error = error as NSError? {
                    completion(nil, error)
                }
                self.save(user: result?.user, completion: {
                    completion(result, nil)
                })
            }
    }
    func sendAppleSignInRequest(with token: String, completion: @escaping(AuthDataResult?, NSError?) -> Void) {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: token, accessToken: nil)
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error as NSError? {
                completion(nil, error)
            }
            self.save(user: result?.user, completion: {
                completion(result, nil)
            })
            completion(result, nil)
        }
    }
    
    func handleMultiFactorAuthentication(error: NSError) {
        let authError = error as NSError
        if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
            // The user is a multi-factor user. Second factor challenge is required.
            let resolver = authError
                .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
            var displayNameString = ""
            for tmpFactorInfo in resolver.hints {
                displayNameString += tmpFactorInfo.displayName ?? ""
                displayNameString += " "
            }
            self.showTextInputPrompt(
                withMessage: "Select factor to sign in\n\(displayNameString)",
                completionBlock: { userPressedOK, displayName in
                    var selectedHint: PhoneMultiFactorInfo?
                    for tmpFactorInfo in resolver.hints {
                        if displayName == tmpFactorInfo.displayName {
                            selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                        }
                    }
                    PhoneAuthProvider.provider()
                        .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                           multiFactorSession: resolver
                                            .session) { verificationID, error in
                            if error != nil {
                                print(
                                    "Multi factor start sign in failed. Error: \(error.debugDescription)"
                                )
                            } else {
                                self.showTextInputPrompt(
                                    withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                    completionBlock: { userPressedOK, verificationCode in
                                        let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                            .credential(withVerificationID: verificationID!,
                                                        verificationCode: verificationCode!)
                                        let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                            .assertion(with: credential!)
                                        resolver.resolveSignIn(with: assertion!) { authResult, error in
                                            if error != nil {
                                                print(
                                                    "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                                )
                                            } else {
                                                self.navigationController?.popViewController(animated: true)
                                            }
                                        }
                                    }
                                )
                            }
                        }
                }
            )
        } else {
            self.displayError(error)
            return
        }
        return
    }
    
    private func save(user: User?, completion: @escaping () -> Void) {
        user?.getIDToken(completion: { token, error in
            UserDefaults.standard.set(user?.uid, forKey: Constants.UserDefaults_Key_UID)
            completion()
        })
    }
}
