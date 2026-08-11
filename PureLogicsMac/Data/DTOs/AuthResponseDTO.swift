//
//  AuthResponseDTO.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


import Foundation

//Read Auth response
struct AuthResponseDTO: Decodable, Sendable {
    let message: String?
    let errorCode : Int?
    let id: String?
    let email: String?
    let publicKey: String?
    let privateKey: String?
    let privateKeyIter: Int?
    let privateKeySalt: String?
    let passwordIter: Int?
    let passwordSalt: String?
    let defaultCloud: String?
    let numberOfDevices: Int?
    let serverCurrentDate: String?
    let subscription: String?
    let subscriptionDetails: SubscriptionDetailsDTO?
}
struct SubscriptionDetailsDTO: Decodable, Sendable {
    let platform: String
    let platformDetails: PlatformDetailsDTO?
}
struct PlatformDetailsDTO: Decodable, Sendable {
    let purchaseDate: String?
    let expiryDate: String?
    let cardExpiryDate: String?
    let cardLastFourDigits: String?
    let activationKey: String?
}

//Error response
struct AuthResponseDTOError: Decodable, Sendable {
    let message: String
    let errorCode: String
}

enum APIError: LocalizedError {
    case invalidCredentials         // Error Code 9
    case sessionExpired             // Error Code 10
    case serverError(code: String, message: String)

    static func map(code: String?, message: String) -> APIError {
        switch code {
        case "9":
            return .invalidCredentials
        case "10":
            return .sessionExpired
        default:
            return .serverError(code: code ?? "0", message: message)
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .sessionExpired:
            return "Session expired. Please log in again."
        case .serverError(_, let message):
            return message
        }
    }
}

//CheckUserExistDTO
struct CheckUserExistsDTO : Decodable, Sendable {
    let message : String
    let userId : String?
    let activation : String?
}

struct SignUpVerificationData : Hashable, Sendable {
    let email: String
    let password : String
    let pinCode: String
    let activationCode : String?
}

struct postJsonForCreateAcc: Codable, Sendable{
    let id : String
    let email : String
    let proCode: String?
    let pubKey: String
    let privKeyIter: String
    let privKeySalt: String
    let privKey: String
    let passIter: String
    let passSalt: String
    let passHash: String
}
