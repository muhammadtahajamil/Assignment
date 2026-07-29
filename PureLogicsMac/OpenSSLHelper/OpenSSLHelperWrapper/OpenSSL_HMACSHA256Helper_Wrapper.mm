//
//  OpenSSL_HMACSHA256_Wrapper.m
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import "OpenSSL_HMACSHA256Helper_Wrapper.h"
#import "OpenSSL_HMACSHA256Helper.h"

@implementation OpenSSL_HMACSHA256Helper_Wrapper

+ (BOOL)computeHMACSHA256:(const NSString *)data key:(const NSMutableString *)key ouptut:(NSMutableString *)output {
        std::string cppData = [data UTF8String];
        std::string cppKey = [key UTF8String];
        std::string cppOutput;

        if (!OpenSSL_HMACSHA256Helper::ComputeHMACSHA256(cppData, cppKey, cppOutput)) {
            return NO; // Error occurred
        }

        [output setString:[NSString stringWithUTF8String:cppOutput.c_str()]];
        return YES;
}

+ (BOOL)computeHMACSHA256:(const NSData *)data key:(const NSData *)key output:(NSMutableData *)output {
    
        std::vector<unsigned char> cppData((const unsigned char*)data.bytes, (const unsigned char*)data.bytes + data.length);
        std::vector<unsigned char> cppKey((const unsigned char*)key.bytes, (const unsigned char*)key.bytes + key.length);
        std::vector<unsigned char> cppOutput;

        if (!OpenSSL_HMACSHA256Helper::ComputeHMACSHA256(cppData, cppKey, cppOutput)) {
            return NO; // Error occurred
        }

        [output setLength:cppOutput.size()];
        memcpy(output.mutableBytes, cppOutput.data(), cppOutput.size());

        return YES;
}

@end
