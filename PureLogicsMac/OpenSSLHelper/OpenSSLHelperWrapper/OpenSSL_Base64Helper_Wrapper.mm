//
//  OpenSSL_Base64Helper_Wrapper.m
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import "OpenSSL_Base64Helper_Wrapper.h"
#import "OpenSSL_Base64Helper.h"

@implementation OpenSSL_Base64Helper_Wrapper

+ (BOOL)encode:(const NSData *)data output:(NSString **)output{
    // Convert NSData to std::vector<unsigned char>
        std::vector<unsigned char> cppData((unsigned char*)data.bytes, (unsigned char*)data.bytes + data.length);

        // Call the C++ function
        std::string cppOutput;
        bool success = OpenSSL_Base64Helper::Encode(cppData, cppOutput);

        // Convert the output back to NSString
        if (success) {
            *output = [NSString stringWithCString:cppOutput.c_str() encoding:NSUTF8StringEncoding];
        } else {
            output = nil;
        }

        return success;
}
+ (BOOL)decode:(const NSString *)data output:(NSMutableData **)output{
    // Convert NSString to std::string
        std::string cppBase64String = [data UTF8String];

        // Call the C++ function
        std::vector<unsigned char> cppOutput;
        bool success = OpenSSL_Base64Helper::Decode(cppBase64String, cppOutput);

        // Convert the output back to NSData
        if (success) {
            NSMutableData *mutableOutputData = [[NSMutableData alloc] initWithBytes:cppOutput.data() length:cppOutput.size()];
            *output = mutableOutputData;
        } else {
            *output = nil;
        }

        return success;
}

@end
