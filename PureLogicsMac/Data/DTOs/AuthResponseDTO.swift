//
//  AuthResponseDTO.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


import Foundation

struct AuthResponseDTO: Decodable, Sendable {
    let message: String?
    let id: String
    let email: String
    let publicKey: String
    let privateKey: String
    let privateKeyIter: Int
    let privateKeySalt: String
    let passwordIter: Int
    let passwordSalt: String
    let defaultCloud: String?
    let numberOfDevices: Int
    let serverCurrentDate: String
    let subscription: String
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
