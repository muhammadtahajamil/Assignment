//
//  OpenSSL_Helper_Wrapper.h
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#ifndef OpenSSL_Helper_Wrapper_h
#define OpenSSL_Helper_Wrapper_h

#import<Foundation/Foundation.h>

@interface OpenSSL_Helper_Wrapper : NSObject

+ (BOOL)rsaEncryptBase64Encode:(const NSData *)input derEncodedPublicKey:(const NSData *)derEncodedPublicKey output:(NSMutableString **) output;


+ (BOOL)base64DecodeRsaDecrypt:(const NSString *)input derEncodedPrivateKey:(const NSData *) derEncodedPrivateKey output:(NSMutableData **) output;

+ (BOOL)aesEncryptBase64Encode:(const NSData *)input aesKey:(const NSData *) aesKey output:(NSMutableString **)output;

+ (BOOL)base64DecodeAesDecrypt:(const NSString *)input aesKey:(const NSData *)aesKey output:(NSMutableData **)output;

@end


#endif /* OpenSSL_Helper_Wrapper_h */
