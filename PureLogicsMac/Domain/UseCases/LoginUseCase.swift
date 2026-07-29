//
//  LoginUseCase.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


import Foundation

actor LoginUseCase : Sendable {

    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(
        email: String,
        password: String,
        deviceId: String
    ) async throws -> UserSession {
        return try await repository.login(
            email: email,
            password: password,
            deviceId: deviceId
        )
    }
    
    func readAuth(param: String) async throws -> AuthResponseDTO {
        return try await repository.readAuth(parameter: param)
    }
}
