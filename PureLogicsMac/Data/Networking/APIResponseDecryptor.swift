//
//  APIDecryptionError.swift
//  PureLogicsMac
//
//  Created by Apple on 27/07/2026.
//


import Foundation

enum APIDecryptionError: LocalizedError {
    case emptyCipher
    case invalidCipherFormat
    case decryptionFailed

    var errorDescription: String? {
        switch self {
        case .emptyCipher:
            return "Encrypted response is empty."

        case .invalidCipherFormat:
            return "Encrypted response format is invalid."

        case .decryptionFailed:
            return "Unable to decrypt server response."
        }
    }
}

protocol APIResponseDecrypting : Sendable {
    func decryptAPIResponse(_ cipher: String) throws -> String
}

final class APIResponseDecryptor: APIResponseDecrypting {

    func decryptAPIResponse(_ cipher: String) throws -> String {
        guard !cipher.isEmpty else {
            throw APIDecryptionError.emptyCipher
        }

        let parsed = try parseEncryptedResponse(cipher)

        let crypt = CryptLib()

        guard let decryptedText = crypt.decryptCipherTextRandomIV(
            withCipherText: parsed.finalCipherText,
            key: parsed.key
        ) else {
            throw APIDecryptionError.decryptionFailed
        }

        return decryptedText
    }

    private func parseEncryptedResponse(_ cipher: String) throws -> ParsedEncryptedResponse {
        guard cipher.count > 23 else {
            throw APIDecryptionError.invalidCipherFormat
        }

        let first8EndIndex = cipher.index(cipher.startIndex, offsetBy: 8)
        let first8Characters = String(cipher[..<first8EndIndex])

        let afterFirst8 = cipher[first8EndIndex...]

        guard afterFirst8.count >= 15 else {
            throw APIDecryptionError.invalidCipherFormat
        }

        let keyEndIndex = afterFirst8.index(afterFirst8.startIndex, offsetBy: 15)
        let key = String(afterFirst8[..<keyEndIndex])
        let remainingEncryptedText = String(afterFirst8[keyEndIndex...])

        let finalCipherText = first8Characters + remainingEncryptedText

        return ParsedEncryptedResponse(
            key: key,
            finalCipherText: finalCipherText
        )
    }
}

private struct ParsedEncryptedResponse {
    let key: String
    let finalCipherText: String
}

