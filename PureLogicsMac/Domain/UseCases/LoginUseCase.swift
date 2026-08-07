//
//  LoginUseCase.swift
//  PureLogicsMac
//
//  Created by Apple on 28/07/2026.
//


import Foundation

actor LoginUseCase : Sendable {

    private let repository: AuthRepository

    let crypt = CryptLib()
    
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
    
    func callAPIAsync(url: URL, parameter: String, completion: @escaping (Bool, String) -> Void) {
        // Simplified the redundant String -> Data -> String -> Data conversion
        guard let postData = parameter.data(using: .utf8) else {
            completion(false, "")
            
            return
        }
        
        print("Url : \(url.absoluteString)")
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = postData
        request.setValue("macOS", forHTTPHeaderField: "App-Platform")
        request.timeoutInterval = 5
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Alamofire defaults to main queue for completions.
            // We wrap URLSession's callback to maintain that exact behavior.
            DispatchQueue.main.async {
                
                // 1. Handle Errors
                if let error = error {
                    if let urlError = error as? URLError {
                        if urlError.code == .timedOut {
                            
                            completion(false, "\(urlError.code.rawValue)")
                            return
                        } else {
                            // Matches original logic returning the error code enum/struct
                            completion(false, "\(urlError.code)")
                            return
                        }
                    } else {
                        completion(false, "\(error)")
                        return
                    }
                }
                
                // 2. Handle missing data
                guard let data = data else {
                    completion(false, "")
                    return
                }
                
                // 3. Handle Success Data
                if let returnData = String(data: data, encoding: .utf8) {
                    Task{
                        await completion(true, self.getDecUId(cipher: returnData))
                    }
                    return
                } else {
                    completion(false, "")
                    return
                }
            }
        }
        
        // URLSession requires you to explicitly start the task
        task.resume()
    }
    
    func getDecUId(cipher :String)->String{
        let string1 = cipher.prefix(8)
        let result1 = cipher.split(separator: string1)
        
        let string2 = result1[0].prefix(15)
        
        let result2 = result1[0].split(separator: string2)
        let lastPart : String = String(result2[0])
        
        let crypText = string1 + lastPart
        
        let decCipher = self.DecText(text: String(crypText), forkey: String(string2))
        return decCipher
    }
    func DecText(text:String, forkey:String)->String{
        let vp = crypt.decryptCipherTextRandomIV(withCipherText: text as String, key: forkey)
        // print("DecypherText \(vp! as String)")
        return vp ?? "Nil value found"
    }
    
   }

