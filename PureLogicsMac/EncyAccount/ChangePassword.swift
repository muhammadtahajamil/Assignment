//
//  ChangePassword.swift
//  FolderLock
//
//  Created by MacBook on 04/06/2024.
//

import Foundation

class ChangePassword{
    
    func changeAccountPassword(password: NSData, derEncodedPrivateKey: NSData, privateKeyKdfIterations: Int32, passwordHashKdfIterations: Int32) -> [Any]{
        
        var base64EncodedPasswordHashSalt: NSString?
        var base64EncodedPrivateKeySalt: NSString?
        var base64EncodedSecurePrivateKey: NSString?
        var base64EncodedPasswordHash: NSString?
        var privateKeyKdfIterations = privateKeyKdfIterations
        var passwordHashKdfIterations = passwordHashKdfIterations
                
        guard SecureAccount_Wrapper.changePassword(
            password as Data,
            derEncodedPrivateKey: derEncodedPrivateKey as Data,
            privateKeyKdfIterations: privateKeyKdfIterations,
            base64EncodedPrivateKeySalt: &base64EncodedPrivateKeySalt,
            base64EncodedSecurePrivateKey: &base64EncodedSecurePrivateKey,
            passwordHashKdfIterations: passwordHashKdfIterations,
            base64EncodedPasswordHashSalt: &base64EncodedPasswordHashSalt,
            base64EncodedPasswordHash: &base64EncodedPasswordHash
        ) else{
            return ["", "", "", "", false]
        }
        return [base64EncodedPasswordHashSalt as Any, base64EncodedPrivateKeySalt as Any, base64EncodedSecurePrivateKey as Any, base64EncodedPasswordHash as Any, true]
    }
}
