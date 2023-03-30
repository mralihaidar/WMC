//
//  JSONDecoder+Ex.swift
//  WorldMedicalCard
//
//  Created by Adeel-dev on 3/1/22.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static let appCustomStrategy: Self = {
        return .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            if let timeIntervalSince1970 = try? container.decode(Double.self) {
                return Date(timeIntervalSince1970: timeIntervalSince1970)
            } else if let timeString = try? container.decode(String.self) {

                let defaultFormatter = ISO8601DateFormatter()

                let fractionSecondFormatter = ISO8601DateFormatter()
                fractionSecondFormatter.formatOptions = fractionSecondFormatter.formatOptions.union(.withFractionalSeconds)

                let defaultFormatterWithoutTimezone = ISO8601DateFormatter()
                defaultFormatterWithoutTimezone.formatOptions.remove(.withTimeZone)

                let fractionSecondFormatterWithoutTimezone = ISO8601DateFormatter()
                fractionSecondFormatterWithoutTimezone.formatOptions = fractionSecondFormatterWithoutTimezone.formatOptions.union(.withFractionalSeconds)
                fractionSecondFormatterWithoutTimezone.formatOptions.remove(.withTimeZone)

                if let date = defaultFormatter.date(from: timeString) ??
                    fractionSecondFormatter.date(from: timeString) ??
                    defaultFormatterWithoutTimezone.date(from: timeString) ??
                    fractionSecondFormatterWithoutTimezone.date(from: timeString) {
                    return date
                } else {
                    let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected date string or unix value")
                    throw DecodingError.dataCorrupted(context)
                }
            } else {
                let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected date string or unix value")
                throw DecodingError.dataCorrupted(context)
            }
        }
    }()
}

extension JSONDecoder {
    static let appDefault: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appCustomStrategy
        return decoder
    }()
}
