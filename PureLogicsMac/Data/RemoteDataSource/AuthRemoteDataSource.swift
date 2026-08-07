//
//  AuthRemoteDataSource.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


import Foundation

protocol AuthRemoteDataSource: Sendable {
    func login(request: LoginRequestDTO) async throws -> LoginResponseDTO
    func readAuth(parameter: String) async throws -> AuthResponseDTO
}

struct DefaultAuthRemoteDataSource: AuthRemoteDataSource {
    
    private let apiClient: DefaultAPIClient
    private let encryptor: APIRequestEncrypting

    init(
        apiClient: DefaultAPIClient,
        encryptor: APIRequestEncrypting = APIRequestEncryptor()
    ) {
        self.apiClient = apiClient
        self.encryptor = encryptor
    }

    func login(request: LoginRequestDTO) async throws -> LoginResponseDTO {
        let endpoint = AuthEndpoint.login(request)

        return try await apiClient.requestDecodable(
            LoginResponseDTO.self,
            endpoint: endpoint
        )
    }

    func readAuth(parameter: String) async throws -> AuthResponseDTO {
        let encryptedParameter = try encryptor.encryptEmailParameter(parameter)
        let endpoint = AuthEndpoint.readAuth(parameter: encryptedParameter)

        return try await apiClient.requestDecodable(
            AuthResponseDTO.self,
            endpoint: endpoint
        )
    }
}
