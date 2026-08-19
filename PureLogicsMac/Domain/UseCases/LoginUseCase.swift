//
//  LoginUseCase.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


import Foundation
import Security


actor LoginUseCase : Sendable {

    private let repository: AuthRepository
//    private let keychainRepository : KeychainRepositoryProtocol

    
    init(
        repository: AuthRepository
    ) {
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
        do {
            let authInfo = try await repository.readAuth(parameter: email)
            print("Login response == ",authInfo.message!)
            guard authInfo.message == "success" else {
                guard authInfo.errorCode == 9 else {
                    throw LoginError.unknowError
                }
                throw LoginError.userNotExist
            }
               // 2. Perform Cryptographic Password Verification
               // 3. Throw domain error if password fails
               guard isValidPassword(password: password, authInfo: authInfo) else {
                   throw LoginError.invalidPassword
               }
               return authInfo
        } catch{
            throw NetworkError.noInternetConnection
        }
        
       }
     func isValidPassword(password :String ,authInfo : AuthResponseDTO) -> Bool {
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
        guard isValid else {
            return false
        }
        return true
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
        UserDefaults.standard.set(userId, forKey: "fl10_deviceId")
        
        
        //also add get id from keychains
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
    
    func saveToKeychain(value :String, key:String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Always delete any existing item before saving to avoid duplicate errors
        SecItemDelete(query as CFDictionary)
        
        // Add the new item to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Error saving to Keychain: \(status)")
        }
    }
    
    func getIdFromKC(key: String) -> String? {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
            
            // If successful, convert the raw data back to a String
            if status == errSecSuccess, let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
            
            return nil
        }
}

