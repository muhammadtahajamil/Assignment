//
//  EncryptAccountDetails.swift
//  FolderLock
//
//  Created by MacBook on 07/06/2024.
//

import Foundation

class EncryptAccountDetails{
    
    
    func encryptAccountDetails(email: String, passwordSha256Hash: Data, derEncodedPrivateKeySha256Hash: NSData, subscription: String, defaultCloud: String, userStatus: String, numberOfDevices: String, cardExpiry: String, cardLastFourDigits: String, subscriptionDate: String, subscriptionExpiryDate : String, activationCode: String) -> [Any]{
        
        var aesEncryptedBase64EncodedAccountDetails : NSString?
        
        guard SecureAccount_Wrapper.encryptUserAccountDetails(
            email,
            passwordSha256Hash: passwordSha256Hash,
            derEncodedPrivateKeySha256Hash: derEncodedPrivateKeySha256Hash as Data,
            subscription: subscription,
            defaultCloud: defaultCloud,
            userStatus: userStatus,
            numberOfDevices: numberOfDevices,
            cardExpiry: cardExpiry,
            cardLastFourDigits: cardLastFourDigits,
            subscriptionDate: subscriptionDate,
            subscriptionExpiryDate: subscriptionExpiryDate,
            activationCode: activationCode,
            aesEncryptedBase64EncodedAccountDetails: &aesEncryptedBase64EncodedAccountDetails)else{
            
            return ["", false]
        }
        
        return [aesEncryptedBase64EncodedAccountDetails as Any, true]
    }
}
