//
//  SecureAccount_Wrapper.h
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#ifndef SecureAccount_Wrapper_h
#define SecureAccount_Wrapper_h

#import <Foundation/Foundation.h>

@interface SecureAccount_Wrapper : NSObject

+ (BOOL)createAccount:(NSData *)password
             derEncodedPublicKey:(NSData **)derEncodedPublicKey
             derEncodedPrivateKey:(NSData **)derEncodedPrivateKey
             base64DerEncodedPublicKey:(NSString **)base64DerEncodedPublicKey
             privateKeyKdfIterations:(int)privateKeyKdfIterations
             base64EncodedPrivateKeySalt:(NSString **)base64EncodedPrivateKeySalt
             base64EncodedSecurePrivateKey:(NSString **)base64EncodedSecurePrivateKey
             passwordHashKdfIterations:(int)passwordHashKdfIterations
             base64EncodedPasswordHashSalt:(NSString **)base64EncodedPasswordHashSalt
             base64EncodedPasswordHash:(NSString **)base64EncodedPasswordHash;

+ (BOOL)verifyAccount:(NSData *)password
         base64DerEncodedPublicKey:(NSString *)base64DerEncodedPublicKey
              derEncodedPublicKey:(NSData **)derEncodedPublicKey
            privateKeyKdfIterations:(int)privateKeyKdfIterations
     base64EncodedPrivateKeySalt:(NSString *)base64EncodedPrivateKeySalt
  base64EncodedSecurePrivateKey:(NSString *)base64EncodedSecurePrivateKey
              derEncodedPrivateKey:(NSData **)derEncodedPrivateKey;

+ (BOOL)changePassword:(NSData *)password
              derEncodedPrivateKey:(NSData *)derEncodedPrivateKey
           privateKeyKdfIterations:(int)privateKeyKdfIterations
     base64EncodedPrivateKeySalt:(NSString **)base64EncodedPrivateKeySalt
  base64EncodedSecurePrivateKey:(NSString **)base64EncodedSecurePrivateKey
      passwordHashKdfIterations:(int)passwordHashKdfIterations
   base64EncodedPasswordHashSalt:(NSString **)base64EncodedPasswordHashSalt
         base64EncodedPasswordHash:(NSString **)base64EncodedPasswordHash;

+ (BOOL)encryptUserAccountDetails:(NSString *)email
               passwordSha256Hash:(NSData *)passwordSha256Hash
   derEncodedPrivateKeySha256Hash:(NSData *)derEncodedPrivateKeySha256Hash
                     subscription:(NSString *)subscription
                     defaultCloud:(NSString *)defaultCloud
                       userStatus:(NSString *)userStatus
                  numberOfDevices:(NSString *)numberOfDevices
                       cardExpiry:(NSString *)cardExpiry
               cardLastFourDigits:(NSString *)cardLastFourDigits
                 subscriptionDate:(NSString *)subscriptionDate
           subscriptionExpiryDate:(NSString *)subscriptionExpiryDate
                   activationCode:(NSString *)activationCode
aesEncryptedBase64EncodedAccountDetails:(NSString **)aesEncryptedBase64EncodedAccountDetails;

+ (BOOL)decryptUserAccountDetails:(NSString *)email
               passwordSha256Hash:(NSData *)passwordSha256Hash
   derEncodedPrivateKeySha256Hash:(NSData *)derEncodedPrivateKeySha256Hash
   aesEncryptedBase64EncodedAccountDetails:(NSString *)aesEncryptedBase64EncodedAccountDetails
                              subscription:(NSString **)subscription
                              defaultCloud:(NSString **)defaultCloud
                                userStatus:(NSString **)userStatus
                           numberOfDevices:(NSString **)numberOfDevices
                                cardExpiry:(NSString **)cardExpiry
                        cardLastFourDigits:(NSString **)cardLastFourDigits
                          subscriptionDate:(NSString **)subscriptionDate
                    subscriptionExpiryDate:(NSString **)subscriptionExpiryDate
                            activationCode:(NSString **)activationCode;


@end



#endif /* SecureAccount_Wrapper_h */
