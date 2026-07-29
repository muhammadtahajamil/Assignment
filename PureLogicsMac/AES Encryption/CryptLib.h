//
//  CryptLib.h
//  FolderLock
//
//  Created by Apple on 14/03/2023.
//

#ifndef CryptLib1_h
#define CryptLib1_h


#endif /* CryptLib_h */

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Foundation/Foundation.h>



@interface CryptLib : NSObject

-  (NSData *)encrypt:(NSData *)plainText key:(NSString *)key iv:(NSString *)iv;
-  (NSData *)decrypt:(NSData *)encryptedText key:(NSString *)key iv:(NSString *)iv;
-  (NSData *)generateRandomIV:(size_t)length;
-  (NSString *) md5:(NSString *) input;
-  (NSString *) sha256:(NSString *)key length:(NSInteger) length;
-  (NSString *) encryptPlainText:(NSString *)plainText key:(NSString *)key iv:(NSString *)iv;
-  (NSString *) decryptCipherText:(NSString *)cipherText key:(NSString *)key iv:(NSString *)iv;
-  (NSString *) encryptPlainTextRandomIVWithPlainText:(NSString *)plainText key:(NSString *)key;
-  (NSString *) decryptCipherTextRandomIVWithCipherText:(NSString *)cipherText key:(NSString *)key;

@end
