//
//  myvault_rsa.h
//  iosvault
//
//  Created by admin on 2/12/21.
//
#ifndef myvault_rsa_h
#define myvault_rsa_h

#import <Foundation/Foundation.h>

int rsa_encrypt_sharp(char* pubKey, unsigned char* plainData, int plainDataSize, unsigned char** encryptedData);
int rsa_decrypt_sharp(char *privateKey, unsigned char *encData, int encDataSize, unsigned char **plainData);
int generate_rsa_keyEx(NSData** out_pub_key, NSData** out_pri_key);

// NSData
int rsa_encrypt_nsdata(NSData* pubKey, NSData* plainData, int plainDataSize, NSData** encryptedData);
int rsa_decrypt_nsdata(NSData* privateKey, NSData* encData, int encDataSize, NSData** plainData);

#endif /* myvault_rsa_h */
