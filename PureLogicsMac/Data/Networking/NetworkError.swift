//
//  NetworkError.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


import Foundation

enum NetworkError: LocalizedError {
    
    case invalidResponse
    case invalidStatusCode(Int)
    case invalidUTF8Response
    case decodingFailed
    case requestFailed(Error)
    case noInternetConnection

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."

        case .invalidStatusCode(let code):
            return "Server returned status code \(code)."

        case .invalidUTF8Response:
            return "Unable to read encrypted response."

        case .decodingFailed:
            return "Unable to decode decrypted response."

        case .requestFailed(let error):
            return error.localizedDescription

        case .noInternetConnection:
            return "No internet connection."
        }
    }
}
