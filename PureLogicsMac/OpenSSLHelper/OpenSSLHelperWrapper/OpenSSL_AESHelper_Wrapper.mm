//
//  OpenSSL_AESHelper_Wrapper.m
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import "OpenSSL_AESHelper_Wrapper.h"
#import "OpenSSL_AESHelper.h"

@implementation OpenSSL_AESHelper_Wrapper

+ (BOOL)encryptIV:(const NSData *) key iv:(const NSData *) iv plaintext:(const NSString *) plaintext ciphertext:(NSMutableData *)ciphertext{
    
        std::vector<unsigned char> cppKey(reinterpret_cast<const unsigned char *>(key.bytes), reinterpret_cast<const unsigned char *>(key.bytes) + key.length);
        std::vector<unsigned char> cppIv(reinterpret_cast<const unsigned char *>(iv.bytes), reinterpret_cast<const unsigned char *>(iv.bytes) + iv.length);

        // Convert NSString to std::string
        std::string cppPlaintext([plaintext UTF8String]);

        // Call the C++ function
        std::vector<unsigned char> cppCiphertext;
        bool success = OpenSSL_AESHelper::Encrypt(cppKey, cppIv, cppPlaintext, cppCiphertext);

        // Convert the output back to NSMutableData
        if (success) {
            [ciphertext setData:[NSData dataWithBytes:cppCiphertext.data() length:cppCiphertext.size()]];
        }

        return success;
    
}

+ (BOOL)encrypt:(const NSData *)key plaintext:(const NSData *)plaintext ciphertext:(NSMutableData *)ciphertext{
    
        std::vector<unsigned char> cppKey((unsigned char*)key.bytes, (unsigned char*)key.bytes + key.length);
        std::vector<unsigned char> cppPlaintext((unsigned char*)plaintext.bytes, (unsigned char*)plaintext.bytes + plaintext.length);

        // Call the C++ function
        std::vector<unsigned char> cppCiphertext;
        bool success = OpenSSL_AESHelper::Encrypt(cppKey, cppPlaintext, cppCiphertext);

        // Convert the output back to NSMutableData
        if (success) {
            [ciphertext setData:[NSData dataWithBytes:cppCiphertext.data() length:cppCiphertext.size()]];
        }

        return success;
}

+ (BOOL)decrypt:(const NSData *)key ciphertext:(const NSData *)ciphertext plaintext:(NSMutableData *)plaintext{
    
    std::vector<unsigned char> cppKey((unsigned char*)key.bytes, (unsigned char*)key.bytes + key.length);
       std::vector<unsigned char> cppCiphertext((unsigned char*)ciphertext.bytes, (unsigned char*)ciphertext.bytes + ciphertext.length);

       // Call the C++ function
       std::vector<unsigned char> cppPlaintext;
       bool success = OpenSSL_AESHelper::Decrypt(cppKey, cppCiphertext, cppPlaintext);

       // Convert the output back to NSMutableData
       if (success) {
           [plaintext setData:[NSData dataWithBytes:cppPlaintext.data() length:cppPlaintext.size()]];
       }

       return success;
   
}

+ (BOOL)decryptIV:(const NSData *)key iv:(const NSData *)iv ciphertext:(const NSData *) ciphertext plaintext:(NSString *)plaintext{
    
    std::vector<unsigned char> cppKey((unsigned char*)key.bytes, (unsigned char*)key.bytes + key.length);
        std::vector<unsigned char> cppIv((unsigned char*)iv.bytes, (unsigned char*)iv.bytes + iv.length);
        std::vector<unsigned char> cppCiphertext((unsigned char*)ciphertext.bytes, (unsigned char*)ciphertext.bytes + ciphertext.length);

        // Call the C++ function
        std::string cppPlaintext;
        bool success = OpenSSL_AESHelper::Decrypt(cppKey, cppIv, cppCiphertext, cppPlaintext);

        // Convert the output back to NSString
        if (success) {
            plaintext = [[NSString alloc] initWithBytes:cppPlaintext.data() length:cppPlaintext.size() encoding:NSUTF8StringEncoding];
        } else {
            plaintext = nil;
        }

        return success;
    
}

@end
