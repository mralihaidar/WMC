//
//  ApiProvider+Request.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/1/22.
//

import Foundation
import FirebaseAuth
import Alamofire

// MARK: - Api provider
final class ApiProvider: NSObject {
    //Note: - Using Alamofire Refresh token with `AuthenticationCredential`
    static let `default` = ApiProvider(authenticator: MainAuthProvider.shared)

    let authenticator: MainAuthProvider
    init(authenticator: MainAuthProvider) {
        self.authenticator = authenticator
    }

    var interceptor: AuthenticationInterceptor<MainAuthProvider> {
        AuthenticationInterceptor(authenticator: authenticator, credential: authenticator.credential)
    }
}

// MARK: - general data request
extension ApiProvider {
    func request(_ target: URLRequestConvertible) -> DataRequest {
        return Session
            .default
            .request(target, interceptor: interceptor)
            .validate()
    }

    func upload(_ target: URLRequestConvertible, fileName: String, data: Data?, mimeType: String, fileTitle: String, fileDescription: String?, categoryId: Int) -> DataRequest {
        return Session.default
            .upload(multipartFormData: { (multipartData) in
                if let data = data {
                    multipartData.append(data, withName: "FileData", fileName: fileName.lowercased(), mimeType: mimeType)
                }
                var parameters = Parameters()
                parameters["FileTitle"] = fileTitle
                parameters["FileDescription"] = fileDescription
                parameters["FileCategoryId"] = categoryId
                for (key, value) in parameters {
                    if let data = (value as? String)?.data(using: .utf8) {
                        multipartData.append(data, withName: key)
                    } else if let data = value as? Int {
                        multipartData.append("\(data)".data(using: .utf8)!, withName: key)
                    }
                }
            }, with: target, interceptor: interceptor)
            .validate()
    }
    
    func download(_ target: URLRequestConvertible) -> DownloadRequest {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask, options: [.removePreviousFile, .createIntermediateDirectories])
        return Session
            .default
            .download(target, interceptor: interceptor, to: destination)
            .validate()
    }
}
