//
//  AuthRepository.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//

protocol AuthRepository: Sendable {
    func login(email: String, password: String, deviceId: String) async throws -> UserSession
    func readAuth(parameter: String) async throws -> AuthResponseDTO
    func checkUserExist(parameter:String) async throws -> CheckUserExistsDTO
    func sendPinCode(parameter:String) async throws -> String
    func createUserId(parameter:String) async throws -> String
    func signUp(parameter:String) async throws -> CheckUserExistsDTO
}


