////
////  SignupRemoteDataSource.swift
////  PureLogicsMac
////
////  Created by Apple on 07/08/2026.
////
//
//protocol SignupRemoteDataSource : Sendable {
//    func signup(parameters: String) async throws -> String
//    func checkUserExists(parameters: String) async throws -> CheckUserExists
//}
//
//struct SignupRemoteDataSourceImplementation : SignupRemoteDataSource {
//    
//    private let apiClient: DefaultAPIClient
//    private let encryptor: APIRequestEncrypting
//
//    init(
//        apiClient: DefaultAPIClient,
//        encryptor: APIRequestEncrypting = APIRequestEncryptor()
//    ) {
//        self.apiClient = apiClient
//        self.encryptor = encryptor
//    }
//    
//    func signup(parameters: String) async throws -> String {
//        return "taha"
//    }
//    
//    func checkUserExists(parameters: String) async throws -> CheckUserExists {
//        let encryptedParameters = try encryptor.encryptParameter(parameters)
//        let endPoint =  AuthEndpoint.checkExistingDevice(parameter: parameters)
//        
//        return try await apiClient.requestDecodable(
//            CheckUserExists.self,
//            endpoint: endPoint)
//    }
//}
