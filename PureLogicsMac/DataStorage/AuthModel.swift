//
//  AuthModel.swift
//  PureLogicsMac
//
//  Created by Apple on 12/08/2026.
//

import Foundation
import SwiftData

@Model
final class UserSessionModel {
    // Unique constraint ensures each user account gets 1 record on this device
    @Attribute(.unique) var userId: String
    var email: String
    var message: String?
    var publicKey: String?
    var privateKey: String?
    var privateKeyIter: Int?
    var privateKeySalt: String?
    var passwordIter: Int?
    var passwordSalt: String?
    var defaultCloud: String?
    var numberOfDevices: Int?
    var serverCurrentDate: String?
    var subscription: String?
    var lastLoginDate: Date
    // One-to-one relationship with cascade deletion
    @Relationship(deleteRule: .cascade)
    var subscriptionDetails: SubscriptionDetailsModel?

    init(
        userId: String,
        email: String,
        message: String? = nil,
        publicKey: String? = nil,
        privateKey: String? = nil,
        privateKeyIter: Int? = nil,
        privateKeySalt: String? = nil,
        passwordIter: Int? = nil,
        passwordSalt: String? = nil,
        defaultCloud: String? = nil,
        numberOfDevices: Int? = nil,
        serverCurrentDate: String? = nil,
        subscription: String? = nil,
        subscriptionDetails: SubscriptionDetailsModel? = nil,
        lastLoginDate: Date = Date()
    ) {
        self.userId = userId
        self.email = email
        self.message = message
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.privateKeyIter = privateKeyIter
        self.privateKeySalt = privateKeySalt
        self.passwordIter = passwordIter
        self.passwordSalt = passwordSalt
        self.defaultCloud = defaultCloud
        self.numberOfDevices = numberOfDevices
        self.serverCurrentDate = serverCurrentDate
        self.subscription = subscription
        self.subscriptionDetails = subscriptionDetails
        self.lastLoginDate = lastLoginDate
    }
}

@Model
final class SubscriptionDetailsModel {
    var platform: String
    var purchaseDate: String?
    var expiryDate: String?
    var cardExpiryDate: String?
    var cardLastFourDigits: String?
    var activationKey: String?
    
    init(
        platform: String,
        purchaseDate: String? = nil,
        expiryDate: String? = nil,
        cardExpiryDate: String? = nil,
        cardLastFourDigits: String? = nil,
        activationKey: String? = nil
    ) {
        self.platform = platform
        self.purchaseDate = purchaseDate
        self.expiryDate = expiryDate
        self.cardExpiryDate = cardExpiryDate
        self.cardLastFourDigits = cardLastFourDigits
        self.activationKey = activationKey
    }
}


//struct DeviceDTOList: Sendable, Hashable {
//    let devices: [DeviceDTO]?
//}
//
//struct DeviceDTO: Identifiable, Sendable, Hashable {
//    let id: String
//    let name: String
//    let platform: String
//}

@Model
final class UserDevicesModel{
    
    @Relationship(deleteRule: .cascade)
    var devices: [DevicesInfo]?
    
    init(devices: [DevicesInfo]) {
        self.devices = devices
    }
}

@Model
final class DevicesInfo{
    @Attribute(.unique)var id  : String
    var name: String
    var platform: String
    
    init(id: String, name: String, platform: String) {
        self.id = id
        self.name = name
        self.platform = platform
    }
}
