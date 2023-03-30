//
//  Api.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/1/22.
//

import Foundation
import Alamofire

// MARK: - Api target type

struct AnyEncodable: Encodable {
    
    private let encodable: Encodable
    
    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }
    
    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}

enum TargetEncoding {
    case plain
    case data(Data)
    case jsonEncodable(Encodable, encoder: JSONEncoder?)
    case parameters(Parameters, encoding: ParameterEncoding)
    case customParameters(String, RecordItem)
}

protocol Target: URLRequestConvertible {
    var url: URL { get }
    var httpMethod: HTTPMethod { get }
    var targetEncoding: TargetEncoding { get }
    var headers: HTTPHeaders? { get }
}

// default Target implementation
extension Target {
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var targetEncoding: TargetEncoding {
        return .plain
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    // URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers?.dictionary
        
        switch targetEncoding {
            case .plain:
                return request
            case .data(let data):
                request.httpBody = data
                return request
            case .jsonEncodable(let encodable, let encoder):
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                var encoder = encoder
                if encoder == nil {
                    encoder = JSONEncoder()
                    encoder?.dateEncodingStrategy = .iso8601
                }
                let data = try encoder?.encode(AnyEncodable(encodable))
                request.httpBody = data
            case .parameters(let parameters, let encoding):
                request = try encoding.encode(request, with: parameters)
            case .customParameters(let type, let item):
                //Delete a record.
                //Query parameters with json body
                //TODO: - Refactor it later
                var urlComponent = URLComponents(string: (request.url?.absoluteString)!)
                let queryItems = [URLQueryItem(name: "type", value: type)]
                urlComponent?.queryItems = queryItems
                var newRequest = URLRequest(url: (urlComponent?.url)!)
                newRequest.httpMethod = httpMethod.rawValue
                newRequest.allHTTPHeaderFields = headers?.dictionary
                newRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(AnyEncodable(item))
                newRequest.httpBody = data
                return newRequest
        }
        return request
    }
}

enum Api {
    ///user
    case getUser
    case postUser(UserProfile)
    
    ///dashboard Items
    case getDashboardItems(page: Int, pageSize: Int, type: String, lanugage: String?)
    
    ///card
    case postOrderCard
    
    ///Record Items
    case getRecordItems(text: String, page: Int, pageSize: Int, type: String)
    case postRecordItems(_ type: String, recordItem: RecordItem)
    case deleteRecordItem(_ type: String, recordItem: RecordItem)
    
    ///Document Categories
    case getDocumentCategories(page: Int, pageSize: Int)
    case postDocument
    case getDocuments(page: Int, pageSize: Int)
    case deleteDocument(_ id: String)
    case editDocument(_ id: String)
    case getDocument(_ id: String)
    case share(_ type: String, outputFormat: String)
    
    ///Translate
    case getLanguages

    // Subscriptions
    case getOwnerSubscriptions
    case getMemberSubscriptions
    case getSubscriptionDetail(id: Int)
    case cancelSubscription(id: Int)
    case inviteSubscriptionMember(subscriptionId: Int, email: String)
    case removeSubscriptionMember(subscriptionId: Int, memberId: Int)
}
extension Api: Target {
    
    var baseUrl: URL {
        guard let baseUrl = URL(string: Environment.apiBaseUrl) else {
            fatalError("API Base Url is missing")
        }
        return baseUrl
    }
    var url: URL {
        return baseUrl.appendingPathComponent(path)
    }
    
    var path: String {
        switch self {
            case .getUser, .postUser:
                return "users/profile"
            case .getDashboardItems:
                return "profiles/items"
            case .getRecordItems:
                return "profiles/items/search"
            case .postRecordItems:
                return "profiles/items"
            case .deleteRecordItem:
                return "profiles/items"
            case .getDocumentCategories:
                return "documents/categories"
            case .postDocument, .getDocuments:
                return "documents"
            case .deleteDocument(let id), .editDocument(let id):
                return "documents/\(id)"
            case .getDocument(let id):
                return "documents/file/\(id)"
            case .share:
                return "profiles/items/share"
            case .postOrderCard:
                return "users/card"
            case .getLanguages:
                return "translations/languages"

            case .getOwnerSubscriptions:
                return "users/subscriptions"
            case .getMemberSubscriptions:
                return "users/subscriptions/member"
            case .getSubscriptionDetail:
                return "users/subscriptions/Detail"
            case .cancelSubscription:
                return "users/subscriptions"
            case .inviteSubscriptionMember:
                return "users/subscriptions/member"
            case .removeSubscriptionMember:
                return "users/subscriptions/member"
        }
    }
    var headers: HTTPHeaders? {
        return nil
    }
    var httpMethod: HTTPMethod {
        switch self {
            case .getUser, .getDashboardItems, .getRecordItems, .getDocumentCategories, .getDocuments, .getDocument, .share, .getLanguages:
                return .get
            case .postUser, .postRecordItems, .postDocument, .postOrderCard:
                return .post
            case .deleteRecordItem, .deleteDocument:
                return .delete
            case .editDocument:
                return .put

            case .getOwnerSubscriptions, .getMemberSubscriptions, .getSubscriptionDetail:
                return .get
            case .cancelSubscription:
                return .put
            case .inviteSubscriptionMember:
                return .post
            case .removeSubscriptionMember:
                return .delete
        }
    }
    var targetEncoding: TargetEncoding {
        switch self {
            case .getUser:
                return .plain
            case .getDashboardItems(let page, let pageSize, let type, let language):
                var parameters = Parameters()
                parameters["Page"] = page
                parameters["PageSize"] = pageSize
                parameters["type"] = type
                parameters["lang"] = language == nil ? Constants.currentLanguage : language
                return .parameters(parameters, encoding: URLEncoding.default)
            case .postRecordItems(let type, let item):
                return .customParameters(type, item)
            case .deleteRecordItem(let type, let item):
                return .customParameters(type, item)
            case .getRecordItems(let text, let page, let pageSize, let type):
                var parameters = Parameters()
                parameters["Page"] = page
                parameters["PageSize"] = pageSize
                parameters["lang"] = Constants.currentLanguage
                parameters["key"] = text
                parameters["type"] = type
                return .parameters(parameters, encoding: URLEncoding.default)
            case .getDocumentCategories(let page, let pageSize):
                var parameters = Parameters()
                parameters["Page"] = page
                parameters["PageSize"] = pageSize
                parameters["lang"] = Constants.currentLanguage
                return .parameters(parameters, encoding: URLEncoding.default)
            case .getDocuments(let page, let pageSize):
                var parameters = Parameters()
                parameters["Page"] = page
                parameters["PageSize"] = pageSize
                return .parameters(parameters, encoding: URLEncoding.default)
            case .postUser(let profile):
                return .jsonEncodable(profile, encoder: nil)
            case .share(let type, let outputFormat):
                var parameters = Parameters()
                parameters["type"] = type
                parameters["outputFormat"] = outputFormat
                parameters["lang"] = Constants.currentLanguage
                return .parameters(parameters, encoding: URLEncoding.default)
            case .postOrderCard:
                var parameters = Parameters()
                parameters["lang"] = Constants.currentLanguage
                return .parameters(parameters, encoding: URLEncoding.default)
            case .getOwnerSubscriptions, .getMemberSubscriptions:
                return .plain
            case .getSubscriptionDetail(let id):
                return .parameters(["id": id], encoding: URLEncoding.default)
        case .cancelSubscription(let id):
                return .parameters(["id": id], encoding: URLEncoding.queryString)
            case .inviteSubscriptionMember(let subscriptionId, let email):
                return .parameters(["subscriptionId": subscriptionId, "email": email],
                                   encoding: JSONEncoding.default)
            case .removeSubscriptionMember(let subscriptionId, let memberId):
                return .parameters(["subscriptionId": subscriptionId, "customerId": memberId],
                                   encoding: JSONEncoding.default)
            default:
                return .plain
        }
    }
}

