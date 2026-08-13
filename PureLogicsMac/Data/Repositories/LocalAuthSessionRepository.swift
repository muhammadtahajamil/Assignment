//
//  LocalAuthSessionRepositoryProtocol.swift
//  PureLogicsMac
//
//  Created by Apple on 12/08/2026.
//


import Foundation
import SwiftData

@MainActor
protocol LocalAuthSessionRepositoryProtocol {
    func saveOrUpdateSession(from dto: AuthResponseDTO) throws
    func fetchAllSavedSessions() throws -> [UserSessionModel]
    func fetchSession(userId: String) throws -> UserSessionModel?
    func deleteSession(userId: String) throws
    //func deleteAllsessions() In future
}

@MainActor
final class LocalAuthSessionRepository: LocalAuthSessionRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Appends new user session or updates existing user session in SwiftData
    func saveOrUpdateSession(from dto: AuthResponseDTO) throws {
        guard let userId = dto.id, !userId.isEmpty else {
            throw NSError(
                domain: "AuthRepository", 
                code: 400, 
                userInfo: [NSLocalizedDescriptionKey: "User ID is required to save session."]
            )
        }

        let targetEmail = dto.email ?? ""
        
        // 1. Check if user already exists in SwiftData
        let descriptor = FetchDescriptor<UserSessionModel>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        let existingSessions = try modelContext.fetch(descriptor)
        
        if let existingUser = existingSessions.first {
            // 2. UPDATE existing user data
            existingUser.email = targetEmail
            existingUser.message = dto.message
            existingUser.publicKey = dto.publicKey
            existingUser.privateKey = dto.privateKey
            existingUser.numberOfDevices = dto.numberOfDevices
            existingUser.subscription = dto.subscription
            existingUser.lastLoginDate = Date() // update timestamp
            
            if let subDTO = dto.subscriptionDetails {
                existingUser.subscriptionDetails = SubscriptionDetailsModel(
                    platform: subDTO.platform,
                    purchaseDate: subDTO.platformDetails?.purchaseDate,
                    expiryDate: subDTO.platformDetails?.expiryDate,
                    cardExpiryDate: subDTO.platformDetails?.cardExpiryDate,
                    cardLastFourDigits: subDTO.platformDetails?.cardLastFourDigits,
                    activationKey: subDTO.platformDetails?.activationKey
                )
            }
        } else {
            // 3. APPEND new user session record
            let newUserSession = UserSessionModel(
                userId: userId,
                email: targetEmail,
                message: dto.message,
                publicKey: dto.publicKey,
                privateKey: dto.privateKey,
                privateKeyIter: dto.privateKeyIter,
                privateKeySalt: dto.privateKeySalt,
                passwordIter: dto.passwordIter,
                passwordSalt: dto.passwordSalt,
                defaultCloud: dto.defaultCloud,
                numberOfDevices: dto.numberOfDevices,
                serverCurrentDate: dto.serverCurrentDate,
                subscription: dto.subscription,
                subscriptionDetails: dto.subscriptionDetails.map { subDTO in
                    SubscriptionDetailsModel(
                        platform: subDTO.platform,
                        purchaseDate: subDTO.platformDetails?.purchaseDate,
                        expiryDate: subDTO.platformDetails?.expiryDate,
                        cardExpiryDate: subDTO.platformDetails?.cardExpiryDate,
                        cardLastFourDigits: subDTO.platformDetails?.cardLastFourDigits,
                        activationKey: subDTO.platformDetails?.activationKey
                    )
                },
                lastLoginDate: Date()
            )
            modelContext.insert(newUserSession)
        }
        
        // 4. Save changes to SwiftData disk database
        try modelContext.save()
    }

    /// Fetch all user accounts that have logged into this device
    func fetchAllSavedSessions() throws -> [UserSessionModel] {
        let descriptor = FetchDescriptor<UserSessionModel>(
            sortBy: [SortDescriptor(\.lastLoginDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch session for a specific user ID
    func fetchSession(userId: String) throws -> UserSessionModel? {
        let descriptor = FetchDescriptor<UserSessionModel>(
            predicate: #Predicate { $0.userId == userId }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func fetchSessionByEmail(email: String) throws -> UserSessionModel? {
        let descriptor = FetchDescriptor<UserSessionModel>(
            predicate: #Predicate { $0.email == email }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    /// Delete a user session (e.g. if user removes account from device)
    func deleteSession(userId: String) throws {
        if let sessionToDelete = try fetchSession(userId: userId) {
            modelContext.delete(sessionToDelete)
            try modelContext.save()
        }
    }
}
