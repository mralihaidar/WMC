//
//  AuthProvider.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/1/22.
//


import Foundation
import Alamofire
import FirebaseAuth

struct AuthCredential: AuthenticationCredential {

    let accessToken: String
    var requiresRefresh: Bool {
        guard let expiration = JWT(token: accessToken).expirationDate else { return false }
        return Date(timeIntervalSinceNow: 60 * 5) > expiration
    }
}

class MainAuthProvider: NSObject, Authenticator {
    
    static let shared = MainAuthProvider(name: "AuthenticationData", keychain: Keychain.default)
    
    private let authDataKey: String
    private var accessToken: String?
    private var keychain = Keychain.default
    
    // MARK: - Initializer
    required init(name: String, keychain: Keychain) {
        self.authDataKey = name
        self.keychain = keychain
        super.init()
        accessToken = keychain.string(forKey: authDataKey)
    }

    var credential: AuthCredential {
        return AuthCredential(accessToken: accessToken ?? "")
    }

    // MARK: Authenticator
    
    func apply(_ credential: AuthCredential, to urlRequest: inout URLRequest) {
        urlRequest.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        urlRequest.timeoutInterval = 60
        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
    }
    
    func refresh(_ credential: AuthCredential, for session: Session, completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "Invalid user", code: 0)))
            return
        }

        user.getIDTokenForcingRefresh(true) { [weak self] (token, error) in
            guard let sSelf = self else {
                return
            }
            
            guard let token = token else {
                print("Token refreshing was failed 😭. Log user out!")
                NotificationCenter.default.post(name: .logoutUser, object: nil)

                let err = error ?? NSError(domain: "Token refreshing failed", code: 0)
                completion(.failure(err))
                return
            }

            print("Token is refreshed successfully 🏁!")
            sSelf.accessToken = token
            sSelf.keychain.set(token, forKey: sSelf.authDataKey)

            completion(.success(AuthCredential(accessToken: token)))
        }
    }
    
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool {
        return response.statusCode == 401
    }
    
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: AuthCredential) -> Bool {
        true
    }
}

extension MainAuthProvider {
    func cleanUp() {
        keychain.set(nil, forKey: authDataKey)
        accessToken = nil
    }
}
