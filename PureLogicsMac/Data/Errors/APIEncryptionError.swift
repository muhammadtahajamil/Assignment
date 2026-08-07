//
//  APIEncryptionError.swift
//  PureLogicsMac
//
//  Created by Apple on 30/07/2026.
//


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
