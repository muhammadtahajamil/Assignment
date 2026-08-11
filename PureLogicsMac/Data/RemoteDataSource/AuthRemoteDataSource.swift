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
    func checkUserExist(parameter: String) async throws -> CheckUserExistsDTO
    func sendPinCode(parameter : String) async throws -> String
    func createUserId(parameter : String) async throws -> String
    func signUp(parameter:String) async throws -> CheckUserExistsDTO
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
    
    func checkUserExist(parameter: String) async throws -> CheckUserExistsDTO {
        let encryptedParameter = try encryptor.encryptParameter(parameter)
        let endpoint = AuthEndpoint.userIsRegistered(parameter: encryptedParameter)
        
        return try await apiClient.requestDecodable(
            CheckUserExistsDTO.self,
            endpoint: endpoint
        )
    }
    
    func sendPinCode(parameter: String) async throws -> String {
        let encryptedParameter = try encryptor.encryptParameter(parameter)
        let endpoint = AuthEndpoint.sendPinCode(parameter: encryptedParameter)
        
        return try await apiClient.requestDecryptedString(endpoint: endpoint)
    }
    
    func createUserId(parameter: String) async throws -> String {
        let encParam = try encryptor.encryptParameter(parameter)
        let endPoint = AuthEndpoint.createUserOrDeviceIDURL(parameter: encParam)
        
        return try await apiClient.requestDecryptedString(endpoint: endPoint)
    }
    
    func signUp(parameter: String) async throws -> CheckUserExistsDTO {
        let encParam = try encryptor.encryptParameter(parameter)
        let endPoint = AuthEndpoint.userSignup(parameter: encParam)
        
        return try await apiClient.requestDecodable(
            CheckUserExistsDTO.self,
            endpoint: endPoint
        )
    }
    
}
