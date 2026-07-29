//
//  myvault_aes.h
//  iosvault
//
//  Created by admin on 3/11/21.
//

#ifndef myvault_aes_h
#define myvault_aes_h
#import <Foundation/Foundation.h>

int sum(int a , int b);


int aes_encrypt_sharp(NSData* keyData, NSData* salt, NSData* plainText, NSData** encData);
int aes_decrypt_sharp(NSData *keyData, int keyDataLen,
                      NSData *salt, NSData *encData,
                      int encDataLen, NSData **plainData);

#endif /* myvault_aes_h */
