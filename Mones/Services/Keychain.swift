//
//  Keychain.swift
//  Mones
//
//  Created by Zakhar on 09.11.25.
//
import Foundation
import CryptoKit
import Security


struct PasscodeRecord: Codable {
    let salt: Data
    let hash: Data
}

enum KeychainError: Error { case notFound, unexpectedData, unhandled(OSStatus) }

enum Keychain {
    static func save(data: Data, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String:             kSecClassGenericPassword,
            kSecAttrAccount as String:       account,
            kSecAttrAccessible as String:    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData as String:         data
        ]
        SecItemDelete(query as CFDictionary) // overwrite
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandled(status) }
    }

    static func read(account: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String:           kSecClassGenericPassword,
            kSecAttrAccount as String:     account,
            kSecReturnData as String:      kCFBooleanTrue!,
            kSecMatchLimit as String:      kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.notFound }
        guard status == errSecSuccess, let data = item as? Data else { throw KeychainError.unexpectedData }
        return data
    }

    static func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

func randomSalt(_ count: Int = 16) -> Data {
    var buf = Data(count: count)
    buf.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, count, $0.baseAddress!) }
    return buf
}

func hashPIN(_ pin: String, salt: Data) -> Data {
    var hasher = SHA256()
    hasher.update(data: salt)
    hasher.update(data: Data(pin.utf8))
    return Data(hasher.finalize())
}
