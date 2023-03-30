//
//  Keychain.swift
//  WorldMedicalCard
//
//  Created by Abhishek on 03/02/22.
//

import Foundation
import Security

class Keychain: NSObject {
    private let service: String
    required init(serviceName: String) {
        self.service = serviceName
        super.init()
    }

    static let `default` = Keychain(serviceName: "WATT_Keychain_Service")

    private func query(forKey key: String) -> [CFString: Any] {
        return [
            kSecAttrService: service,
//            kSecAttrAccessGroup: accessGroup,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
    }

    func data(forKey key: String) -> Data? {
        var query = self.query(forKey: key)
        query[kSecReturnData] = kCFBooleanTrue
        query[kSecMatchLimit] = kSecMatchLimitOne

        var result: CFTypeRef?
        SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }

    @discardableResult
    func set(data: Data?, forKey key: String) -> Bool {
        var query = self.query(forKey: key)
        if let data = data {
            var status = errSecSuccess
            if self.data(forKey: key) != nil {
                // there's already existing data for this key, update it
                status = SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary)
            } else {
                //no existing data, add a new item
                query[kSecValueData] = data
                status = SecItemAdd(query as CFDictionary, nil)
            }

            if status != errSecSuccess {
                return false
            }

        } else if self.data(forKey: key) != nil {
            // delete existing data
            let status = SecItemDelete(query as CFDictionary)
            if status != errSecSuccess {
                return false
            }
        } else {
            // nothing to do
        }

        return true
    }
}

extension Keychain {

    /// Store value to the key chain. Set **nil** clear value if existing.
    ///
    /// - Parameters:
    ///   - value: Value that will be set.
    ///   - key: Key to retrieve value.
    /// - Returns: **True** if successful. Otherwise, return **false**.
    @discardableResult
    func set(_ value: Any?, forKey key: String) -> Bool {
        if let data = value as? Data {
            return set(data: data, forKey: key)
        } else if let value = value {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
                return set(data: data, forKey: key)
            } catch {
                return false
            }
        } else {
            return set(data: nil, forKey: key)
        }
    }

    /// Get **value** from keychain by **key**.
    ///
    /// - Parameter key: Key is used to retrieve keychain item
    /// - Returns: **value** in keychain associated with **key**
    func getValue<T>(forKey key: String) -> T? {
        if let data = data(forKey: key) {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
        }
        return nil
    }
}

extension Keychain {
    func string(forKey key: String) -> String? {
        return getValue(forKey: key)
    }

    func date(forKey key: String) -> Date? {
        return getValue(forKey: key)
    }
}
