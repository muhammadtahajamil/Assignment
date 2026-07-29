//
//  OpenSSL_SHA256Helper_Wrapper.h
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#ifndef OpenSSL_SHA256Helper_Wrapper_h
#define OpenSSL_SHA256Helper_Wrapper_h

#import <Foundation/Foundation.h>

@interface OpenSSL_SHA256Helper_Wrapper : NSObject

+ (NSData *)computeSHA256:(const NSData *)input;

+ (NSData *)computeAESKeySeedDataHash:(NSString *)email
                             password:(NSData *)password
                 derEncodedPrivateKey:(NSData *)derEncodedPrivateKey;

@end


#endif /* OpenSSL_SHA256Helper_Wrapper_h */
