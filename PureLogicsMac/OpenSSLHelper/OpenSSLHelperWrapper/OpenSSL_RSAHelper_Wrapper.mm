//
//  OpenSSL_RSAHelper_Wrapper.m
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import "OpenSSL_RSAHelper_Wrapper.h"
#import "OpenSSL_RSAHelper.h"

@implementation OpenSSL_RSAHelper_Wrapper

+ (BOOL)generateKeys:(NSMutableData **)derEncodedPublicKey derEncodedPrivateKey:(NSMutableData **)derEncodedPrivateKey {
    // Convert NSMutableData to std::vector<unsigned char>
    const unsigned char *publicKeyBytes = (const unsigned char *)[(*derEncodedPublicKey) bytes];
    const unsigned char *privateKeyBytes = (const unsigned char *)[(*derEncodedPrivateKey) bytes];
    std::vector<unsigned char> publicKey(publicKeyBytes, publicKeyBytes + [(*derEncodedPublicKey) length]);
    std::vector<unsigned char> privateKey(privateKeyBytes, privateKeyBytes + [(*derEncodedPrivateKey) length]);

    // Call the C++ function
    bool result = OpenSSL_RSAHelper::GenerateKeys(publicKey, privateKey);

    // Update the NSMutableData objects if necessary
    *derEncodedPublicKey = [NSMutableData dataWithBytes:publicKey.data() length:publicKey.size()];
    *derEncodedPrivateKey = [NSMutableData dataWithBytes:privateKey.data() length:privateKey.size()];
    return result;
}


+ (BOOL)validateKeys:(const NSData *) derPublicKey derPrivateKey:(const NSData *)derPrivateKey{
        
        std::vector<unsigned char> publicKey(static_cast<const unsigned char *>(derPublicKey.bytes), static_cast<const unsigned char *>(derPublicKey.bytes) + derPublicKey.length);
        std::vector<unsigned char> privateKey(static_cast<const unsigned char *>(derPrivateKey.bytes), static_cast<const unsigned char *>(derPrivateKey.bytes) + derPrivateKey.length);
        // Call the C++ function
        return OpenSSL_RSAHelper::ValidateKeys(publicKey, privateKey);
}



+ (BOOL)decrypt:(const NSData *)encryptedData derEncodedPrivateKey:(const NSData *)derEncodedPrivateKey decryptedData:(NSMutableData *)decryptedData {
        const unsigned char *encryptedDataBytes = (const unsigned char *)[encryptedData bytes];
        std::vector<unsigned char> cppEncryptedData(encryptedDataBytes, encryptedDataBytes + [encryptedData length]);

        const unsigned char *privateKeyBytes = (const unsigned char *)[derEncodedPrivateKey bytes];
        std::vector<unsigned char> cppPrivateKey(privateKeyBytes, privateKeyBytes + [derEncodedPrivateKey length]);

        
        std::vector<unsigned char> cppDecryptedData;
        
        // Call the C++ function
        bool success = OpenSSL_RSAHelper::Decrypt(cppEncryptedData, cppPrivateKey, cppDecryptedData);
        
        if (success) {
            // Convert the result back to NSMutableData
            [decryptedData setData:[NSData dataWithBytes:cppDecryptedData.data() length:cppDecryptedData.size()]];
        }
        
        return success;
}

+ (BOOL)encrypt:(const NSData *)data derEncodedPublicKey:(const NSData *)derEncodedPublicKey encryptedData:(NSMutableData *)encryptedData {
        // Convert NSData objects to std::vector<unsigned char>
        const unsigned char *dataBytes = (const unsigned char *)[data bytes];
        std::vector<unsigned char> cppData(dataBytes, dataBytes + [data length]);

        const unsigned char *publicKeyBytes = (const unsigned char *)[derEncodedPublicKey bytes];
        std::vector<unsigned char> cppPublicKey(publicKeyBytes, publicKeyBytes + [derEncodedPublicKey length]);

        
        std::vector<unsigned char> cppEncryptedData;
        
        // Call the C++ function
        bool success = OpenSSL_RSAHelper::Encrypt(cppData, cppPublicKey, cppEncryptedData);
        
        if (success) {
            // Convert the result back to NSMutableData
            [encryptedData setData:[NSData dataWithBytes:cppEncryptedData.data() length:cppEncryptedData.size()]];
        }
        
        return success;
}

@end
