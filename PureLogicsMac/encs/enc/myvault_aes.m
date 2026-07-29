//
//  myvault_aes.m
//  iosvault
//
//  Created by admin on 3/11/21.
//

#import <Foundation/Foundation.h>
#import <OpenSSL/OpenSSL.h>
#import "myvault_base64.h"

int sum(int a , int b) {
    return a + b;
}

int aes_init(unsigned char *keyData, int keyDataLen, unsigned char *salt, EVP_CIPHER_CTX *e_ctx, EVP_CIPHER_CTX *d_ctx)
{

    int i, nrounds = 5;
    unsigned char key[32], iv[32];
    /*
     * Gen key & IV for AES 256 CBC mode. A SHA1 digest is used to hash the supplied key material.
     * nrounds is the number of times the we hash the material. More rounds are more secure but
     * slower.
     */

    i = EVP_BytesToKey(EVP_aes_256_cbc(), EVP_sha1(), salt, keyData, keyDataLen, nrounds, key, iv);
    if (i != 32) {
        printf("Key size is %d bits - should be 256 bits\n", i);
        return -1;
    }

    EVP_CIPHER_CTX_init(e_ctx);
    EVP_EncryptInit_ex(e_ctx, EVP_aes_256_cbc(), NULL, key, iv);
    EVP_CIPHER_CTX_init(d_ctx);
    EVP_DecryptInit_ex(d_ctx, EVP_aes_256_cbc(), NULL, key, iv);

    return 1;
}

int aes_encrypt(EVP_CIPHER_CTX *e, unsigned char *plainText, int plainTextLen, unsigned char** encData) {
    // max ciphertext len for a n bytes of plaintext is n + AES_BLOCK_SIZE -1 bytes
    int c_len = plainTextLen + AES_BLOCK_SIZE;
    int f_len = 0;
    int length = 0;

    unsigned char *ciphertext = (unsigned char *)malloc(c_len+AES_BLOCK_SIZE);
    EVP_EncryptUpdate(e, ciphertext, &c_len, plainText, plainTextLen);
    // update ciphertext with the final remaining bytes
    EVP_EncryptFinal_ex(e, ciphertext + c_len, &f_len);

    length = c_len + f_len;

    *encData = ciphertext;

    return length;
}

int aes_decrypt(EVP_CIPHER_CTX *e, unsigned char *cipherText, int cipherTextLen, unsigned char** plainData)
{
    // plaintext will always be equal to or lesser than length of ciphertext
    int p_len = cipherTextLen;
    int f_len = 0;
    int plainTextLen = 0;

    unsigned char *outBuf = (unsigned char *)malloc(p_len + AES_BLOCK_SIZE);
    //unsigned char *outBuf = (unsigned char *)malloc(p_len);
    EVP_DecryptUpdate(e, outBuf, &p_len, cipherText, cipherTextLen);
    EVP_DecryptFinal_ex(e, outBuf + p_len, &f_len);
    plainTextLen = p_len + f_len;

    *plainData = outBuf;
    return plainTextLen;
}

////////////////////////////////////////////////////////////////////////
// aes for NSData
// if sucess, return the lenth of decrypted buffer
int aes_encrypt_sharp(NSData* keyData, NSData* salt, NSData* plainText, NSData** encData) {
    int ret = 0;
    int len = 0;
    int result = 0;
    
    unsigned char* pKeyData = (unsigned char*) [keyData bytes];
    int pKeyDataLen = (int) [keyData length] / sizeof(unsigned char);
    unsigned char* pSalt = (unsigned char*) [salt bytes];
    int pSaltLen = (int) [salt length] / sizeof(unsigned char);
    unsigned char* pPlainText = (unsigned char*) [plainText bytes];
    int pPlainTextLen = (int) [plainText length] / sizeof(unsigned char);
    unsigned char* pEncData = NULL;
    
    // key init
    EVP_CIPHER_CTX* e_key = EVP_CIPHER_CTX_new();
    EVP_CIPHER_CTX* d_key = EVP_CIPHER_CTX_new();
    salt = NULL;

    result = aes_init(pKeyData, pKeyDataLen, pSalt, e_key, d_key);
    if (result < 0) {
        ret = result;
        goto L_EXIT;
    }

    //unsigned char** temp = NULL;
    len = aes_encrypt(e_key, pPlainText, pPlainTextLen, &pEncData);
    *encData = [NSData dataWithBytes:pEncData length:len];
L_EXIT:
    
    EVP_CIPHER_CTX_free(e_key);
    EVP_CIPHER_CTX_free(d_key);
    
    return len;
}

// if sucess, return the lenth of decrypted buffer
int aes_decrypt_sharp(NSData *keyData, int keyDataLen,
                      NSData *salt, NSData *encData,
                      int encDataLen, NSData **plainData) {
    int ret = 0;
    int result = 0;
    int decLen = 0;
    
    unsigned char* pKeyData = (unsigned char*) [keyData bytes];
    unsigned char* pSalt = (unsigned char*) [salt bytes];
    unsigned char* pEncData = (unsigned char*) [encData bytes];
    unsigned char *pPlainData = NULL;
    
    // key init
    EVP_CIPHER_CTX* e_key = EVP_CIPHER_CTX_new();
    EVP_CIPHER_CTX* d_key = EVP_CIPHER_CTX_new();
    salt = NULL;

    result = aes_init(pKeyData, keyDataLen, pSalt, e_key, d_key);
    if (result < 0) {
        ret = result;
        goto L_EXIT;
    }

    decLen = aes_decrypt(d_key, pEncData, encDataLen, &pPlainData);
    if (decLen > 0) {
        *plainData = [NSData dataWithBytes:pPlainData length:decLen];
    }
    
L_EXIT:
    EVP_CIPHER_CTX_free(e_key);
    EVP_CIPHER_CTX_free(d_key);
    
    return decLen;
}
