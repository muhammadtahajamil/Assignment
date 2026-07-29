//
//  OpenSSL_AESHelper_Wrapper.h
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#ifndef OpenSSL_AESHelper_Wrapper_h
#define OpenSSL_AESHelper_Wrapper_h
#import <Foundation/Foundation.h>

@interface OpenSSL_AESHelper_Wrapper : NSObject

+ (BOOL)encryptIV:(const NSData *) key iv:(const NSData *) iv plaintext:(const NSString *) plaintext ciphertext:(NSMutableData *)ciphertext;

+ (BOOL)encrypt:(const NSData *)key plaintext:(const NSData *)plaintext ciphertext:(NSMutableData *)ciphertext;

+ (BOOL)decrypt:(const NSData *)key ciphertext:(const NSData *)ciphertext plaintext:(NSMutableData *)plaintext;

+ (BOOL)decryptIV:(const NSData *)key iv:(const NSData *)iv ciphertext:(const NSData *) ciphertext plaintext:(NSString *)plaintext;

@end

#endif /* OpenSSL_AESHelper_Wrapper_h */
