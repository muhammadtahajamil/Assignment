//
//  VerifyAccount.swift
//  FolderLock
//
//  Created by MacBook on 04/06/2024.
//

import Foundation

class VerifyAccount{
    
    func verifyUserAccount(password: NSData, privateKeyKdfIterations: NSString, base64DerEncodedPublicKey: NSString, base64EncodedPrivateKeySalt: NSString, base64EncodedSecurePrivateKey: NSString) -> [Any]{
        
        var derEncodedPublicKey: NSData?
        var derEncodedPrivateKey: NSData?
        
        guard SecureAccount_Wrapper.verifyAccount(
            password as Data,
            base64DerEncodedPublicKey: base64DerEncodedPublicKey as String,
            derEncodedPublicKey: &derEncodedPublicKey,
            privateKeyKdfIterations: Int32(privateKeyKdfIterations as String)!,
            base64EncodedPrivateKeySalt: base64EncodedPrivateKeySalt as String,
            base64EncodedSecurePrivateKey: base64EncodedSecurePrivateKey as String,
            derEncodedPrivateKey: &derEncodedPrivateKey
        )else{
            return ["", "", false]
        }
        
        return [derEncodedPublicKey as Any, derEncodedPrivateKey as Any, true]
    }
}
