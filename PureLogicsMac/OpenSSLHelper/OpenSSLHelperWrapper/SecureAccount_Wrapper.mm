//
//  SecureAccount_Wrapper.m
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import "SecureAccount_Wrapper.h"
#import "SecureAccount.h"

@implementation SecureAccount_Wrapper

+ (BOOL)createAccount:(NSData *)password
             derEncodedPublicKey:(NSData **)derEncodedPublicKey
             derEncodedPrivateKey:(NSData **)derEncodedPrivateKey
             base64DerEncodedPublicKey:(NSString **)base64DerEncodedPublicKey
             privateKeyKdfIterations:(int)privateKeyKdfIterations
             base64EncodedPrivateKeySalt:(NSString **)base64EncodedPrivateKeySalt
             base64EncodedSecurePrivateKey:(NSString **)base64EncodedSecurePrivateKey
             passwordHashKdfIterations:(int)passwordHashKdfIterations
             base64EncodedPasswordHashSalt:(NSString **)base64EncodedPasswordHashSalt
        base64EncodedPasswordHash:(NSString **)base64EncodedPasswordHash {
    const unsigned char *passwordBytes = (const unsigned char *)[password bytes];
    std::vector<unsigned char> cppPassword(passwordBytes, passwordBytes + [password length]);
    std::vector<unsigned char> cppDerEncodedPublicKey;
    std::vector<unsigned char> cppDerEncodedPrivateKey;
    std::string cppBase64DerEncodedPublicKey;
    std::string cppBase64EncodedPrivateKeySalt;
    std::string cppBase64EncodedSecurePrivateKey;
    std::string cppBase64EncodedPasswordHashSalt;
    std::string cppBase64EncodedPasswordHash;
    
    bool result = SecureAccount::Create(
                                        cppPassword,
                                        cppDerEncodedPublicKey,
                                        cppDerEncodedPrivateKey,
                                        cppBase64DerEncodedPublicKey,
                                        privateKeyKdfIterations,
                                        cppBase64EncodedPrivateKeySalt,
                                        cppBase64EncodedSecurePrivateKey,
                                        passwordHashKdfIterations,
                                        cppBase64EncodedPasswordHashSalt,
                                        cppBase64EncodedPasswordHash
                                        );
    
    if (result) {
        if (derEncodedPublicKey != NULL) {
            *derEncodedPublicKey = [NSData dataWithBytes:cppDerEncodedPublicKey.data() length:cppDerEncodedPublicKey.size()];
        }
        if (derEncodedPrivateKey != NULL) {
            *derEncodedPrivateKey = [NSData dataWithBytes:cppDerEncodedPrivateKey.data() length:cppDerEncodedPrivateKey.size()];
        }
        if (base64DerEncodedPublicKey != NULL) {
            *base64DerEncodedPublicKey = [NSString stringWithUTF8String:cppBase64DerEncodedPublicKey.c_str()];
        }
        if (base64EncodedPrivateKeySalt != NULL) {
            *base64EncodedPrivateKeySalt = [NSString stringWithUTF8String:cppBase64EncodedPrivateKeySalt.c_str()];
        }
        if (base64EncodedSecurePrivateKey != NULL) {
            *base64EncodedSecurePrivateKey = [NSString stringWithUTF8String:cppBase64EncodedSecurePrivateKey.c_str()];
        }
        if (base64EncodedPasswordHashSalt != NULL) {
            *base64EncodedPasswordHashSalt = [NSString stringWithUTF8String:cppBase64EncodedPasswordHashSalt.c_str()];
        }
        if (base64EncodedPasswordHash != NULL) {
            *base64EncodedPasswordHash = [NSString stringWithUTF8String:cppBase64EncodedPasswordHash.c_str()];
        }
        
    }
    
    return result;
}

+ (BOOL)verifyAccount:(NSData *)password
         base64DerEncodedPublicKey:(NSString *)base64DerEncodedPublicKey
              derEncodedPublicKey:(NSData **)derEncodedPublicKey
            privateKeyKdfIterations:(int)privateKeyKdfIterations
     base64EncodedPrivateKeySalt:(NSString *)base64EncodedPrivateKeySalt
  base64EncodedSecurePrivateKey:(NSString *)base64EncodedSecurePrivateKey
              derEncodedPrivateKey:(NSData **)derEncodedPrivateKey {
    std::vector<unsigned char> cppPassword((const unsigned char *)password.bytes, (const unsigned char *)password.bytes + password.length);
    std::vector<unsigned char> cppDerEncodedPublicKey;
    std::vector<unsigned char> cppDerEncodedPrivateKey;
    
    bool result = SecureAccount::Verify(
        cppPassword,
        [base64DerEncodedPublicKey UTF8String],
        cppDerEncodedPublicKey,
        privateKeyKdfIterations,
        [base64EncodedPrivateKeySalt UTF8String],
        [base64EncodedSecurePrivateKey UTF8String],
        cppDerEncodedPrivateKey
    );
    
    if (result) {
        if (derEncodedPublicKey != NULL) {
            *derEncodedPublicKey = [NSMutableData dataWithBytes:cppDerEncodedPublicKey.data() length:cppDerEncodedPublicKey.size()];
        }
        if (derEncodedPrivateKey != NULL) {
            *derEncodedPrivateKey = [NSMutableData dataWithBytes:cppDerEncodedPrivateKey.data() length:cppDerEncodedPrivateKey.size()];
        }
    }
    
    return result;
}

+ (BOOL)changePassword:(NSData *)password
              derEncodedPrivateKey:(NSData *)derEncodedPrivateKey
           privateKeyKdfIterations:(int)privateKeyKdfIterations
     base64EncodedPrivateKeySalt:(NSString **)base64EncodedPrivateKeySalt
  base64EncodedSecurePrivateKey:(NSString **)base64EncodedSecurePrivateKey
      passwordHashKdfIterations:(int)passwordHashKdfIterations
   base64EncodedPasswordHashSalt:(NSString **)base64EncodedPasswordHashSalt
       base64EncodedPasswordHash:(NSString **)base64EncodedPasswordHash {
    
    // Convert NSData to std::vector<unsigned char>
    std::vector<unsigned char> cppPassword((const unsigned char *)password.bytes, (const unsigned char *)password.bytes + password.length);
    std::vector<unsigned char> cppDerEncodedPrivateKey((const unsigned char *)derEncodedPrivateKey.bytes, (const unsigned char *)derEncodedPrivateKey.bytes + derEncodedPrivateKey.length);
    
    std::string cppBase64EncodedPrivateKeySalt;
    std::string cppBase64EncodedSecurePrivateKey;
    std::string cppBase64EncodedPasswordHashSalt;
    std::string cppBase64EncodedPasswordHash;
    
    // Call the C++ function
    bool result = SecureAccount::ChangePassword(
        cppPassword,
        cppDerEncodedPrivateKey,
        privateKeyKdfIterations,
        cppBase64EncodedPrivateKeySalt,
        cppBase64EncodedSecurePrivateKey,
        passwordHashKdfIterations,
        cppBase64EncodedPasswordHashSalt,
        cppBase64EncodedPasswordHash
    );
    
    // Convert C++ strings to NSString pointers
    *base64EncodedPrivateKeySalt = [NSString stringWithUTF8String:cppBase64EncodedPrivateKeySalt.c_str()];
    *base64EncodedSecurePrivateKey = [NSString stringWithUTF8String:cppBase64EncodedSecurePrivateKey.c_str()];
    *base64EncodedPasswordHashSalt = [NSString stringWithUTF8String:cppBase64EncodedPasswordHashSalt.c_str()];
    *base64EncodedPasswordHash = [NSString stringWithUTF8String:cppBase64EncodedPasswordHash.c_str()];
    
    return result;
}

+ (BOOL)encryptUserAccountDetails:(NSString *)emailAddress
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
aesEncryptedBase64EncodedAccountDetails:(NSString **)aesEncryptedBase64EncodedAccountDetails {

    std::string emailAddressStr = [emailAddress UTF8String];
    const unsigned char *passwordSha256HashBytes = reinterpret_cast<const unsigned char *>([passwordSha256Hash bytes]);
    size_t passwordSha256HashLength = [passwordSha256Hash length];
    const unsigned char *privateKeyBytes = reinterpret_cast<const unsigned char *>([derEncodedPrivateKeySha256Hash bytes]);
    size_t privateKeyLength = [derEncodedPrivateKeySha256Hash length];

    std::string subscriptionStr = [subscription UTF8String];
    std::string defaultCloudStr = [defaultCloud UTF8String];
    std::string userStatusStr = [userStatus UTF8String];
    std::string numberOfDevicesStr = [numberOfDevices UTF8String];
    std::string cardExpiryStr = [cardExpiry UTF8String];
    std::string cardLastFourDigitsStr = [cardLastFourDigits UTF8String];
    std::string subscriptionDateStr = [subscriptionDate UTF8String];
    std::string subscriptionExpiryDateStr = [subscriptionExpiryDate UTF8String];
    std::string activationCodeStr = [activationCode UTF8String];

    std::string encryptedDetails;

    // Call the C++ function
    bool success = SecureAccount::EncryptUserAccountDetails(emailAddressStr, std::vector<unsigned char>(passwordSha256HashBytes, passwordSha256HashBytes + passwordSha256HashLength), std::vector<unsigned char>(privateKeyBytes, privateKeyBytes + privateKeyLength), subscriptionStr, defaultCloudStr, userStatusStr, numberOfDevicesStr, cardExpiryStr, cardLastFourDigitsStr, subscriptionDateStr, subscriptionExpiryDateStr, activationCodeStr, encryptedDetails);

    if (success) {
        *aesEncryptedBase64EncodedAccountDetails = [NSString stringWithUTF8String:encryptedDetails.c_str()];
        return YES;
    } else {
        *aesEncryptedBase64EncodedAccountDetails = nil;
        return NO;
    }
}

+ (BOOL)decryptUserAccountDetails:(NSString *)emailAddress
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
                   activationCode:(NSString **)activationCode {

    // Convert NSString to std::string
    std::string emailAddressStr = [emailAddress UTF8String];
    const unsigned char *passwordSha256HashBytes = reinterpret_cast<const unsigned char *>([passwordSha256Hash bytes]);
    std::vector<unsigned char> passwordSha256HashVec(passwordSha256HashBytes, passwordSha256HashBytes + passwordSha256Hash.length);
    const unsigned char *privateKeyBytes = reinterpret_cast<const unsigned char *>([derEncodedPrivateKeySha256Hash bytes]);
    std::vector<unsigned char> privateKeyVec(privateKeyBytes, privateKeyBytes + [derEncodedPrivateKeySha256Hash length]);
    std::string aesEncryptedBase64EncodedAccountDetailsStr = [aesEncryptedBase64EncodedAccountDetails UTF8String];

    // Call the C++ function
    std::string subscriptionStr, defaultCloudStr, userStatusStr, numberOfDevicesStr, cardExpiryStr, cardLastFourDigitsStr, subscriptionDateStr, subscriptionExpiryDateStr, activationCodeStr;
    bool success = SecureAccount::DecryptUserAccountDetails(emailAddressStr, passwordSha256HashVec, privateKeyVec, aesEncryptedBase64EncodedAccountDetailsStr, subscriptionStr, defaultCloudStr, userStatusStr, numberOfDevicesStr, cardExpiryStr, cardLastFourDigitsStr, subscriptionDateStr, subscriptionExpiryDateStr, activationCodeStr);

    if (success) {
        *subscription = [NSString stringWithUTF8String:subscriptionStr.c_str()];
        *defaultCloud = [NSString stringWithUTF8String:defaultCloudStr.c_str()];
        *userStatus = [NSString stringWithUTF8String:userStatusStr.c_str()];
        *numberOfDevices = [NSString stringWithUTF8String:numberOfDevicesStr.c_str()];
        *cardExpiry = [NSString stringWithUTF8String:cardExpiryStr.c_str()];
        *cardLastFourDigits = [NSString stringWithUTF8String:cardLastFourDigitsStr.c_str()];
        *subscriptionDate = [NSString stringWithUTF8String:subscriptionDateStr.c_str()];
        *subscriptionExpiryDate = [NSString stringWithUTF8String:subscriptionExpiryDateStr.c_str()];
        *activationCode = [NSString stringWithUTF8String:activationCodeStr.c_str()];
        return YES;
    } else {
        return NO;
    }
}


@end
