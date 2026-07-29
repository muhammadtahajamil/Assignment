//
//  DefaultAuthRepository.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


import Foundation

final class DefaultAuthRepository: AuthRepository {

    private let remoteDataSource: AuthRemoteDataSource

    init(remoteDataSource: AuthRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func login(
        email: String,
        password: String,
        deviceId: String
    ) async throws -> UserSession {
        let request = LoginRequestDTO(
            parameter: email,
            password: password,
            deviceId: deviceId
        )

        let response = try await remoteDataSource.login(request: request)

        return UserSession(
            userId: response.userId,
            name: response.name,
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
    }

    func readAuth(parameter: String) async throws -> AuthResponseDTO {
        let dto = try await remoteDataSource.readAuth(parameter: parameter)
        return AuthResponseDTO(message: dto.message, id: dto.id, email: dto.email, publicKey: dto.publicKey, privateKey: dto.privateKey, privateKeyIter: dto.privateKeyIter, privateKeySalt: dto.privateKeySalt, passwordIter: dto.passwordIter, passwordSalt: dto.passwordSalt, defaultCloud: dto.defaultCloud, numberOfDevices: dto.numberOfDevices, serverCurrentDate: dto.serverCurrentDate, subscription: dto.subscription, subscriptionDetails: dto.subscriptionDetails)
    }
}
