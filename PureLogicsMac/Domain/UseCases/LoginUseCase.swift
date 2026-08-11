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
    
//    func readAuth(param: String) async throws -> AuthResponseDTO {
//        return try await repository.readAuth(parameter: param)
//    }
    
    func authenticateUser(email: String, password: String) async throws -> AuthResponseDTO {
           // 1. Fetch remote user auth data
        let authInfo = try await repository.readAuth(parameter: email)
        print("Login response == ",authInfo.message!)
        guard authInfo.message == "success" else {
            guard authInfo.errorCode == 9 else {
                throw LoginError.unknowError
            }
            throw LoginError.userNotExist
        }
           // 2. Perform Cryptographic Password Verification
           let passwordData = password.data(using: .utf8)
           var derEncodedPublicKey: NSData?
           var derEncodedPrivateKey: NSData?
           let isValid = SecureAccount_Wrapper.verifyAccount(
               passwordData,
               base64DerEncodedPublicKey: authInfo.publicKey,
               derEncodedPublicKey: &derEncodedPublicKey,
               privateKeyKdfIterations: Int32(authInfo.privateKeyIter!),
               base64EncodedPrivateKeySalt: authInfo.privateKeySalt,
               base64EncodedSecurePrivateKey: authInfo.privateKey,
               derEncodedPrivateKey: &derEncodedPrivateKey
           )
           // 3. Throw domain error if password fails
           guard isValid else {
               throw LoginError.invalidPassword
           }
           return authInfo
       }
    
    
    @discardableResult
    func checkUserExists(email:String) async throws -> CheckUserExistsDTO {
        let checkUserExistInfo = try await repository.checkUserExist(parameter: email)
        print("Check User Exists API response == \(checkUserExistInfo.message)")
        guard checkUserExistInfo.message == "New User" else {
            throw LoginError.userAlreadyExists
        }
        return checkUserExistInfo
    }
    
    
    func sendPinCode(parameter:String) async throws -> String {
        let pinCode = try await repository.sendPinCode(parameter: parameter)
        print("Pin Code response = \(pinCode)")
        guard pinCode == "Success" else {
            throw LoginError.pinCodeSentFailed
        }
        return pinCode
    }
    
    func createUserId(parameter:String) async throws -> String {
        
        let userId = try await repository.createUserId(parameter: parameter)
        print("User Id response = \(userId)")
        guard userId != "Invalid Parameters" || userId != "Error" else {
            throw LoginError.createUserIdFailure
        }
        return userId
    }
    
    func createAccount(userId:String, email:String, proCode:String, password:String)throws -> String {
        let apiCreateAccount = ApiCreateAccount()
        let passwordData = password.data(using: .utf8)! as NSData
        do {
            let result = try apiCreateAccount.saveAccountToJson(userId: userId, email: email, proCode: proCode, password: passwordData)
            return result
        }catch {
            throw LoginError.createPasswrodFailed
        }
    }
    
    //{"message":"Success","activation":"Empty"}
    func signUpAccount(parameter:String) async throws -> CheckUserExistsDTO {
        let response = try await repository.signUp(parameter: parameter)
        guard response.message == "Success" && response.activation == "Empty" else {
            throw LoginError.signupError
        }
        print("Sign Up response = \(response)")
        return response
    }
   }

