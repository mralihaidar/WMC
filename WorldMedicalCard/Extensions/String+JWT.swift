//
//  String+JWT.swift
//  WorldMedicalCard
//
//  Created by Apphuset on 02/06/2022.
//

import Foundation

struct JWT {
    let token: String
    init(token: String) {
        self.token = token
    }

    var expirationDate: Date? {
        guard let exp = token.jwtDecode()?["exp"] as? Double else { return nil }
        return Date(timeIntervalSince1970: exp)
    }
}

extension String {

    func jwtDecode() -> [String: Any]? {
        let segments = self.components(separatedBy: ".")
        if segments.count > 1 {
            return decodeJWTPart(segments[1])
        } else {
            return nil
        }
    }

    private func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }

    private func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
            return nil
        }

        return payload
    }
}
