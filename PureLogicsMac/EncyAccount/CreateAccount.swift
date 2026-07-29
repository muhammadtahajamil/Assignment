//
//  CreateAccount.swift
//  FolderLock
//
//  Created by MacBook on 03/06/2024.
//

import Foundation

class CreateAccount{
 
    
    func createUserAccount(password: NSData) -> [Any]{
        
        var derEncodedPublicKey: NSData?
        var derEncodedPrivateKey: NSData?
        var base64DerEncodedPublicKey: NSString?
        var base64EncodedPrivateKeySalt: NSString?
        var base64EncodedSecurePrivateKey: NSString?
        var base64EncodedPasswordHashSalt: NSString?
        var base64EncodedPasswordHash: NSString?
        let privateKeyKdfIterations = 10000
        let passwordHashKdfIterations = 10000
                
        guard SecureAccount_Wrapper.createAccount(
                password as Data,
                derEncodedPublicKey: &derEncodedPublicKey,
                derEncodedPrivateKey: &derEncodedPrivateKey,
                base64DerEncodedPublicKey: &base64DerEncodedPublicKey,
                privateKeyKdfIterations: Int32(privateKeyKdfIterations),
                base64EncodedPrivateKeySalt: &base64EncodedPrivateKeySalt,
                base64EncodedSecurePrivateKey: &base64EncodedSecurePrivateKey,
                passwordHashKdfIterations: Int32(passwordHashKdfIterations),
                base64EncodedPasswordHashSalt: &base64EncodedPasswordHashSalt,
                base64EncodedPasswordHash: &base64EncodedPasswordHash
            ) else {
                return ["", "", "", "", "", false, "", "", 0, 0]
            }

        return [
            base64DerEncodedPublicKey as Any,
            base64EncodedPrivateKeySalt as Any,
            base64EncodedSecurePrivateKey as Any,
            base64EncodedPasswordHashSalt as Any,
            base64EncodedPasswordHash as Any,
            true,
            derEncodedPublicKey as Any,
            derEncodedPrivateKey as Any,
            privateKeyKdfIterations,
            passwordHashKdfIterations
        ]

    }
    
}
