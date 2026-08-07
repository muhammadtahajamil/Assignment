//
//  APIEncryptionError.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


import Foundation

protocol APIRequestEncrypting: Sendable {
    func encryptParameter(_ parameter: String) throws -> String
    func encryptData(_ data: Data, key: String) throws -> Data
    func encryptEmailParameter(_ email: String) throws -> String
}

struct APIRequestEncryptor: APIRequestEncrypting {
    
    func encryptParameter(_ parameter: String) throws -> String {
        guard !parameter.isEmpty else {
            throw APIEncryptionError.emptyPayload
        }

        let crypt = CryptLib()
        let randomKey = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(15))
        
        guard let cipherText = crypt.encryptPlainTextRandomIV(withPlainText: parameter, key: randomKey),
              cipherText.count >= 8 else {
            throw APIEncryptionError.encryptionFailed
        }

        let index8 = cipherText.index(cipherText.startIndex, offsetBy: 8)
        let first8 = String(cipherText[..<index8])
        let remainder = String(cipherText[index8...])

        return "\(first8)\(randomKey)\(remainder)"
    }
    

    func encryptEmailParameter(_ email: String) throws -> String {
        let jsonDict: [String: Any] = [
            "email": email
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw APIEncryptionError.encryptionFailed
        }

        return try encryptParameter(jsonString)
    }
    
    


    func encryptData(_ data: Data, key: String) throws -> Data {
        guard !data.isEmpty else {
            throw APIEncryptionError.emptyPayload
        }
        guard let plainString = String(data: data, encoding: .utf8) else {
            throw APIEncryptionError.encryptionFailed
        }
        let encryptedString = try encryptParameter(plainString)
        guard let encryptedData = encryptedString.data(using: .utf8) else {
            throw APIEncryptionError.encryptionFailed
        }
        return encryptedData
    }
}
