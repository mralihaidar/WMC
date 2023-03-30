//
//  Response+Serialization.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/1/22.
//


import Alamofire
//import SPError

// MARK: - map unknown error
extension DataResponse {
    func errorOrUnknown() -> Error {
        return error ?? NSError.unknown
    }
}
// MARK: - Alamofire JSON serializer Adapter for Decodable
final class AlamofireJsonSerializerAdapter<T: Decodable>: DataResponseSerializerProtocol {
    let jsonDecoder: JSONDecoder
    init(jsonDecoder: JSONDecoder) {
        self.jsonDecoder = jsonDecoder
    }
    typealias SerializedObject = T
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        if let error = error {
            self.logError(request: request, error: error, code: response?.statusCode ?? 0)
            if let data = data, let defaultApiError = DefaultApiError(data: data) {
                throw NSError.errorFromAPI(apiError: defaultApiError)
            }
            throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }
        if let data = data {
            do {
                let item = try self.jsonDecoder.decode(T.self, from: data)
                return item
            } catch {
                if let defaultApiError = DefaultApiError(data: data) {
                    throw defaultApiError
                } else {
                    throw AFError.responseSerializationFailed(reason: .customSerializationFailed(error: error))
                }
            }
        }
        throw AFError.responseSerializationFailed(reason: .invalidEmptyResponse(type: "\(T.self)"))
    }
    func logError(request: URLRequest?, error: Error, code: Int) {
//        let path = request?.url?.path
//        let params: [String: Any] = ["Path": path ?? "",
//                      "Method": request?.httpMethod ?? ""]
//        let appError = AppError(code: code, error: error as NSError, params: params)
//        ErrorTracker.handle(appError)
    }
}

// MARK: - Alamofire DataRequest with Decodable
extension DataRequest {
    @discardableResult
    func response<T: Decodable>(
        _ type: T.Type,
        jsonDecoder: JSONDecoder? = nil,
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (AFDataResponse<T>) -> Void)
        -> Self
    {
        let decoder = jsonDecoder ?? .appDefault
        return response(responseSerializer: AlamofireJsonSerializerAdapter<T>(jsonDecoder: decoder), completionHandler: completionHandler)
    }
}

// MARK: - schema encodings
struct DefaultApiError: Codable, Error {
    
    let message: String?
    let errorCode: Int?
    
    init?(data: Data) {
        do {
            self = try JSONDecoder().decode(DefaultApiError.self, from: data)
        } catch {
            return nil
        }
    }
}
