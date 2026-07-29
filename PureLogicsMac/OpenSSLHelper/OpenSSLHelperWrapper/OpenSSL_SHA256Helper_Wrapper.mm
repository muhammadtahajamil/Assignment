//
//  OpenSSL_SHA256Helper_Wrapper.m
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import "OpenSSL_SHA256Helper_Wrapper.h"
#import "OpenSSL_SHA256Helper.h"

@implementation OpenSSL_SHA256Helper_Wrapper

+ (NSData *)computeSHA256:(const NSData *)input {
    // Convert NSData to std::vector<unsigned char>
    std::vector<unsigned char> inputVec([input length]);
    std::memcpy(inputVec.data(), [input bytes], [input length]);
    
    // Call the C++ function
    std::vector<unsigned char> resultVec = OpenSSL_SHA256Helper::ComputeSHA256(inputVec);
    
    // Convert std::vector<unsigned char> to NSData
    NSData *result = [NSData dataWithBytes:resultVec.data() length:resultVec.size()];
    return result;
}

+ (NSData *)computeAESKeySeedDataHash:(NSString *)email
                             password:(NSData *)password
                 derEncodedPrivateKey:(NSData *)derEncodedPrivateKey {
    std::string emailStr([email UTF8String]);
    std::vector<unsigned char> passwordVec((unsigned char *)[password bytes], (unsigned char *)[password bytes] + [password length]);
    std::vector<unsigned char> privateKeyVec((unsigned char *)[derEncodedPrivateKey bytes], (unsigned char *)[derEncodedPrivateKey bytes] + [derEncodedPrivateKey length]);

    std::vector<unsigned char> hash = OpenSSL_SHA256Helper::ComputeAESKeySeedDataHash(emailStr, passwordVec, privateKeyVec);
//    NSLog(@"hello");

    NSData *hashData = [NSData dataWithBytes:hash.data() length:hash.size()];

    return hashData;
}

@end
