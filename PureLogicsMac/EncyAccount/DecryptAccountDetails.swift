//
//  DecryptAccountDetails.swift
//  FolderLock
//
//  Created by MacBook on 07/06/2024.
//

import Foundation

class DecryptAccountDetails{
    
    
    
    func decryptAccountDetails(email: String, passwordSha256Hash: Data, derEncodedPrivateKeySha256Hash: Data, aesEncryptedBase64EncodedAccountDetails: String) -> [Any]{
        
        var subscription : NSString?
        var defaultCloud : NSString?
        var userStatus : NSString?
        var numberOfDevices : NSString?
        var cardExpiry : NSString?
        var cardLastFourDigits : NSString?
        var subscriptionDate : NSString?
        var subscriptionExpiryDate : NSString?
        var activationCode : NSString?
        
        guard SecureAccount_Wrapper.decryptUserAccountDetails(email, passwordSha256Hash: passwordSha256Hash, derEncodedPrivateKeySha256Hash: derEncodedPrivateKeySha256Hash, aesEncryptedBase64EncodedAccountDetails: aesEncryptedBase64EncodedAccountDetails, subscription: &subscription, defaultCloud: &defaultCloud, userStatus: &userStatus, numberOfDevices: &numberOfDevices, cardExpiry: &cardExpiry, cardLastFourDigits: &cardLastFourDigits, subscriptionDate: &subscriptionDate, subscriptionExpiryDate: &subscriptionExpiryDate, activationCode: &activationCode)else{
            
            return ["", "", "", "", "", "", "", "", "", false]
            
        }
        
        return [subscription as Any, defaultCloud as Any, userStatus as Any, numberOfDevices as Any, cardExpiry as Any, cardLastFourDigits as Any, subscriptionDate as Any, subscriptionExpiryDate as Any, activationCode as Any, true]
        
    }
    
    
    
}
