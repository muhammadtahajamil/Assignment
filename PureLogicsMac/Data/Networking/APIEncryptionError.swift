//
//  APIEncryptionError.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


import Foundation

enum APIEncryptionError: LocalizedError {
    case emptyPayload
    case encryptionFailed

    var errorDescription: String? {
        switch self {
        case .emptyPayload:
            return "Payload to encrypt is empty."
        case .encryptionFailed:
            return "Failed to encrypt request payload."
        }
    }
}

protocol APIRequestEncrypting: Sendable {
    func encryptString(_ plainText: String, key: String) throws -> String
    func encryptData(_ data: Data, key: String) throws -> Data
    func encryptEmailParameter(_ email: String) throws -> String
}

final class APIRequestEncryptor: APIRequestEncrypting {

    func encryptEmailParameter(_ email: String) throws -> String {
        let jsonDict: [String: Any] = [
            "email": email
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw APIEncryptionError.encryptionFailed
        }

        let crypt = CryptLib()
        let randomKey = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(15))

        guard let cipherText = crypt.encryptPlainTextRandomIV(withPlainText: jsonString, key: randomKey),
              cipherText.count >= 8 else {
            throw APIEncryptionError.encryptionFailed
        }

        let index8 = cipherText.index(cipherText.startIndex, offsetBy: 8)
        let first8 = String(cipherText[..<index8])
        let remainder = String(cipherText[index8...])

        return "\(first8)\(randomKey)\(remainder)"
    }

    func encryptString(_ plainText: String, key: String) throws -> String {
        guard !plainText.isEmpty else {
            throw APIEncryptionError.emptyPayload
        }

        let crypt = CryptLib()
        guard let encryptedText = crypt.encryptPlainTextRandomIV(
            withPlainText: plainText,
            key: key
        ) else {
            throw APIEncryptionError.encryptionFailed
        }

        return encryptedText
    }

    func encryptData(_ data: Data, key: String) throws -> Data {
        guard !data.isEmpty else {
            throw APIEncryptionError.emptyPayload
        }
        guard let plainString = String(data: data, encoding: .utf8) else {
            throw APIEncryptionError.encryptionFailed
        }
        let encryptedString = try encryptString(plainString, key: key)
        guard let encryptedData = encryptedString.data(using: .utf8) else {
            throw APIEncryptionError.encryptionFailed
        }
        return encryptedData
    }
}