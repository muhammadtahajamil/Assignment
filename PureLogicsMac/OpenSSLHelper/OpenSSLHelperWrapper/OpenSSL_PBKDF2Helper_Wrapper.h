//
//  OpenSSL_PBKDF2Helper_Wrapper.h
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#ifndef OpenSSL_PBKDF2Helper_Wrapper_h
#define OpenSSL_PBKDF2Helper_Wrapper_h

#import <Foundation/Foundation.h>

@interface OpenSSL_PBKDF2Helper_Wrapper : NSObject

+ (BOOL) computePBKDF2_HMAC_SHA512:(const NSData *)password
    salt:(const NSData *)salt
    iterations:(const int)iterations
    derivedBytesCount:(const int)derivedBytesCount
    derivedBytes:(NSMutableData *)derivedBytes;

@end


#endif /* OpenSSL_PBKDF2Helper_Wrapper_h */
