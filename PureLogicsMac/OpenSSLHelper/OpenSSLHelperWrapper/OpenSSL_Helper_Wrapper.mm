//
//  OpenSSL_Helper_Wrapper.m
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import "OpenSSL_Helper_Wrapper.h"
#import "OpenSSL_Helper.h"

@implementation OpenSSL_Helper_Wrapper

+ (BOOL)rsaEncryptBase64Encode:(const NSData *)input derEncodedPublicKey:(const NSData *)derEncodedPublicKey output:(NSMutableString **)output {
    std::vector<unsigned char> cppInput(static_cast<const unsigned char*>(input.bytes), static_cast<const unsigned char*>(input.bytes) + input.length);
    std::vector<unsigned char> cppPublicKey(static_cast<const unsigned char*>(derEncodedPublicKey.bytes), static_cast<const unsigned char*>(derEncodedPublicKey.bytes) + derEncodedPublicKey.length);
    
    
    std::string cppOutput;
    
    // Call the C++ function
    bool success = OpenSSL_Helper::RsaEncryptBase64Encode(cppInput, cppPublicKey, cppOutput);
    
    if (success) {
        // Convert the result back to NSString
        NSString *resultString = [NSString stringWithUTF8String:cppOutput.c_str()];
        [*output setString:resultString];
    }
    
    return success;
}

+ (BOOL)base64DecodeRsaDecrypt:(const NSString *)input derEncodedPrivateKey:(const NSData *) derEncodedPrivateKey output:(NSMutableData **) output{
    
    std::string cppInput = [input UTF8String];
    
    // Convert NSData to std::vector<unsigned char>
    std::vector<unsigned char> cppPrivateKey(reinterpret_cast<const unsigned char*>(derEncodedPrivateKey.bytes), reinterpret_cast<const unsigned char*>(derEncodedPrivateKey.bytes) + derEncodedPrivateKey.length);
    std::vector<unsigned char> cppOutput;
    
    // Call the C++ function
    bool success = OpenSSL_Helper::Base64DecodeRsaDecrypt(cppInput, cppPrivateKey, cppOutput);
    
    if (success) {
        // Convert the result back to NSMutableData
        [*output setData:[NSData dataWithBytes:cppOutput.data() length:cppOutput.size()]];
    }
    
    return success;
    
}

+ (BOOL)aesEncryptBase64Encode:(const NSData *)input aesKey:(const NSData *) aesKey output:(NSMutableString **)output{
    std::vector<unsigned char> cppInput(reinterpret_cast<const unsigned char*>(input.bytes), reinterpret_cast<const unsigned char*>(input.bytes) + input.length);
    std::vector<unsigned char> cppAesKey(reinterpret_cast<const unsigned char*>(aesKey.bytes), reinterpret_cast<const unsigned char*>(aesKey.bytes) + aesKey.length);
    
    
    // Call the C++ function
    std::string cppOutput;
    bool success = OpenSSL_Helper::AesEncryptBase64Encode(cppInput, cppAesKey, cppOutput);
    
    // Convert the output to NSString
    if (success) {
        *output = [NSMutableString stringWithUTF8String:cppOutput.c_str()];
    }
    
    return success;
}

+ (BOOL)base64DecodeAesDecrypt:(const NSString *) input aesKey:(const NSData *)aesKey output:(NSMutableData **)output {
    std::string cppInput = [input UTF8String];
    
    // Convert NSData to std::vector<unsigned char>
    std::vector<unsigned char> cppAesKey(reinterpret_cast<const unsigned char*>(aesKey.bytes), reinterpret_cast<const unsigned char*>(aesKey.bytes) + aesKey.length);
    
    // Call the C++ function
    std::vector<unsigned char> cppOutput;
    bool success = OpenSSL_Helper::Base64DecodeAesDecrypt(cppInput, cppAesKey, cppOutput);
    
    // Convert the output back to NSMutableData
    if (success) {
        [*output setData:[NSData dataWithBytes:cppOutput.data() length:cppOutput.size()]];
    }
    
    return success;
    
}


@end
