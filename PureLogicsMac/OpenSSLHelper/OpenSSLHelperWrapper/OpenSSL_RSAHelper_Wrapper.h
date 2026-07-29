//
//  OpenSSL_RSAHelper_Wrapper.h
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#ifndef OpenSSL_RSAHelper_Wrapper_h
#define OpenSSL_RSAHelper_Wrapper_h
#import <Foundation/Foundation.h>

@interface OpenSSL_RSAHelper_Wrapper : NSObject

+ (BOOL)generateKeys:(NSMutableData **)derEncodedPublicKey derEncodedPrivateKey:(NSMutableData **)derEncodedPrivateKey;

+ (BOOL)validateKeys:(const NSData *) derPublicKey derPrivateKey:(const NSData *)derPrivateKey;

+ (BOOL)encrypt:(const NSData *)data derEncodedPublicKey:(const NSData *) derEncodedPublicKey encryptedData:(NSMutableData *)encryptedData;

+ (BOOL)decrypt:(const NSData *)encryptedData derEncodedPrivateKey:(const NSData *)derEncodedPrivateKey decryptedData:(NSMutableData *) decryptedData;

@end


#endif /* OpenSSL_RSAHelper_Wrapper_h */
