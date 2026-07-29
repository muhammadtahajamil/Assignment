//
//  OpenSSL_PBKDF2Helper_Wrapper.m
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import "OpenSSL_PBKDF2Helper_Wrapper.h"
#import "OpenSSL_PBKDF2Helper.h"

@implementation OpenSSL_PBKDF2Helper_Wrapper

+ (BOOL)computePBKDF2_HMAC_SHA512:(const NSData *)password salt:(const NSData *)salt iterations:(const int)iterations derivedBytesCount:(const int)derivedBytesCount derivedBytes:(NSMutableData *)derivedBytes {
    
        std::vector<unsigned char> cppPassword((const unsigned char*)password.bytes, (const unsigned char*)password.bytes + password.length);
        std::vector<unsigned char> cppSalt((const unsigned char*)salt.bytes, (const unsigned char*)salt.bytes + salt.length);
        std::vector<unsigned char> cppDerivedBytes;
        
        bool result = OpenSSL_PBKDF2Helper::Compute_PBKDF2_HMAC_SHA512(
            cppPassword,
            cppSalt,
            iterations,
            derivedBytesCount,
            cppDerivedBytes);
        
        if (!result) {
            return NO;
        }
        
        [derivedBytes setLength:cppDerivedBytes.size()];
        memcpy(derivedBytes.mutableBytes, cppDerivedBytes.data(), cppDerivedBytes.size());
        
        return YES;

}

@end
