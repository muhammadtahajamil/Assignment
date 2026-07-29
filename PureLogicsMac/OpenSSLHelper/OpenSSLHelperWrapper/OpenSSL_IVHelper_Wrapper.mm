//
//  OpenSSL_IVHelper_Wrapper.m
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import "OpenSSL_IVHelper_Wrapper.h"
#import "OpenSSL_IVHelper.h"

@implementation OpenSSL_IVHelper_Wrapper

+ (BOOL)generateIV:(NSMutableData *)iv {
    std::vector<unsigned char> cppIV;
       
       // Call the C++ function to generate IV
       if (!OpenSSL_IVHelper::GenerateIV(cppIV)) {
           // Error generating IV
           return NO;
       }
       
       // Copy the generated IV bytes to the provided NSMutableData object
       [iv setLength:cppIV.size()];
       memcpy(iv.mutableBytes, cppIV.data(), cppIV.size());
       
       return YES;
}

@end
