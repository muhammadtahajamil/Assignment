//
//  myvault_rsa.m
//  iosvault
//
//  Created by admin on 2/11/21.
//

#import <Foundation/Foundation.h>
#import <OpenSSL/OpenSSL.h>

#import "myvault_base64.h"

int rsa_encrypt(RSA *pubKey, unsigned char* originalData, int dataSize, unsigned char** encryptedData)
{
    int rsaLen = 0;
    int resultLen = 0;

    rsaLen = RSA_size(pubKey);
    unsigned char* encryptedBuf = (unsigned char*)malloc(rsaLen);

    // RSA_public_encrypt() returns the size of the encrypted data
    // (i.e., RSA_size(rsa)). RSA_private_decrypt()
    // returns the size of the recovered plaintext.

    resultLen = RSA_public_encrypt(dataSize, originalData, encryptedBuf, pubKey, RSA_PKCS1_OAEP_PADDING);
    if (resultLen == -1) {
        printf("ERROR: RSA_public_encrypt: %s\n", ERR_error_string(ERR_get_error(), NULL));
        if (encryptedBuf != NULL) {
            free(encryptedBuf);
            encryptedBuf = NULL;
        }
    }
    else {
        *encryptedData = encryptedBuf;
    }

    return resultLen;
}

int rsa_decrypt(RSA *privKey, unsigned char* encryptedData, int dataSize, unsigned char** decryptedData)
{
    int rsaLen = 0;
    int resultLen = 0;

    rsaLen = dataSize; //RSA_size(privKey); // That's how many bytes the decrypted data would be
    unsigned char *decryptedBin = (unsigned char*)malloc(rsaLen);

    resultLen = RSA_private_decrypt(rsaLen, encryptedData, decryptedBin, privKey, RSA_PKCS1_OAEP_PADDING);

    if (resultLen == -1) {
        printf("ERROR: RSA_private_decrypt: %s\n", ERR_error_string(ERR_get_error(), NULL));
        if (decryptedBin != NULL) {
            free(decryptedBin);
            decryptedBin = NULL;
        }
    }
    else {
        decryptedBin[resultLen] = '\0';
        *decryptedData = decryptedBin;
    }

    return resultLen;
}

bool load_public_key(RSA** rsa,char* publicKeyStr)
{
    bool result = true;
    BIO* bio = NULL;
    RSA* rsaTemp = NULL;
    int len = 0;

    if (publicKeyStr == NULL) {
        result = false;
        goto L_EXIT;
    }

    len = (int) strlen((char*)publicKeyStr);
    bio = BIO_new_mem_buf(publicKeyStr, len); // -1: assume string is null terminated
    if (bio == NULL) {
        result = false;
        goto L_EXIT;
    }

    //BIO_set_flags(bio, BIO_FLAGS_BASE64_NO_NL); // NO NL
    rsaTemp = PEM_read_bio_RSAPublicKey(bio, &rsaTemp, NULL, NULL);
    if (!rsaTemp) {
        printf("ERROR: Could not load PUBLIC KEY!  PEM_read_bio_RSA_PUBKEY FAILED: %s\n", ERR_error_string(ERR_get_error(), NULL));
        result = false;
        goto L_EXIT;
    }

    *rsa = rsaTemp;

    L_EXIT:
    if (bio != NULL) {
        BIO_free(bio);
    }

    return result;
}

bool load_private_key(RSA** rsa, char* KeyStr)
{
    bool result = true;
    BIO* bio = NULL;
    RSA* rsaTemp = NULL;
    int len = 0;

    if (KeyStr == NULL) {
        result = false;
        goto L_EXIT;
    }

    len = (int)strlen((char*)KeyStr);
    bio = BIO_new_mem_buf(KeyStr, len); // -1: assume string is null terminated
    if (bio == NULL) {
        result = false;
        goto L_EXIT;
    }

    rsaTemp = PEM_read_bio_RSAPrivateKey(bio, &rsaTemp, NULL, NULL);
    if (!rsaTemp) {
        printf("ERROR: Could not load PUBLIC KEY!  PEM_read_bio_RSA_PrivateKEY FAILED: %s\n", ERR_error_string(ERR_get_error(), NULL));
        result = false;
        goto L_EXIT;
    }

    *rsa = rsaTemp;

    L_EXIT:
    if (bio != NULL) {
        BIO_free(bio);
    }

    return result;
}

////////////////////////////////////////////////////////////////////////////
// rsa for c#
// if sucess, return the lenth of encrypted buffer
int rsa_encrypt_sharp(char* pubKey, unsigned char* plainData, int plainDataSize,
                      unsigned char** encryptedData) {
    int len = 0;
    RSA *rsa = NULL;
    bool result = load_public_key(&rsa, pubKey);
    if (!result) {
        goto L_EXIT;
    }

    len = rsa_encrypt(rsa, plainData, plainDataSize, encryptedData);

    L_EXIT:

    return len;
}

// if sucess, return the lenth of decrypted buffer
int rsa_decrypt_sharp(char *privateKey, unsigned char *encData, int encDataSize,
                      unsigned char **plainData) {
    int len = 0;
    RSA *rsa = NULL;
    bool result = load_private_key(&rsa, privateKey);
    if (!result) {
        goto L_EXIT;
    }

    len = rsa_decrypt(rsa, encData, encDataSize, plainData);

    L_EXIT:

    return len;
}

// return 0 if success, < 0, fail
int generate_rsa_keyEx(NSData** out_pub_key, NSData** out_pri_key) {
    int                ret = 0;
    RSA* rsa = NULL;
    BIGNUM* bne = NULL;
    BIO* bp_public = NULL, * bp_private = NULL;

    int                bits = 1024;
    unsigned long    e = RSA_F4;

    int pri_len = 0;
    int pub_len = 0;
    unsigned char* pri_key = NULL;
    unsigned char* pub_key = NULL;

    // 1. generate rsa key
    bne = BN_new();
    ret = BN_set_word(bne, e);
    if (ret != 1) {
        goto free_all;
    }

    rsa = RSA_new();
    ret = RSA_generate_key_ex(rsa, bits, bne, NULL);
    if (ret != 1) {
        goto free_all;
    }

    // 2. save public key
    //bp_public = BIO_new_file("public.pem", "w+");
    bp_public = BIO_new(BIO_s_mem());
    ret = PEM_write_bio_RSAPublicKey(bp_public, rsa);
    if (ret != 1) {
        goto free_all;
    }

    // 3. save private key
    //bp_private = BIO_new_file("private.pem", "w+");
    bp_private = BIO_new(BIO_s_mem());
    ret = PEM_write_bio_RSAPrivateKey(bp_private, rsa, NULL, NULL, 0, NULL, NULL);

    // Get the length
    pub_len = BIO_pending(bp_public);
    pri_len = BIO_pending(bp_private);

    // the key pair reads the string
    pub_key = (unsigned char*)malloc(pub_len + 1);
    pri_key = (unsigned char*)malloc(pri_len + 1);

    BIO_read(bp_public, (void*) pub_key, pub_len);
    BIO_read(bp_private, (void*) pri_key, pri_len);

    pub_key[pub_len] = '\0';
    pri_key[pri_len] = '\0';

    *out_pub_key = [NSData dataWithBytes: pub_key length:pub_len];
    *out_pri_key = [NSData dataWithBytes: pri_key length:pri_len];


    // 4. free
    free_all:
    
    if (pub_key != NULL) {
        free(pub_key);
    }
    
    if (pri_key != NULL) {
        free(pri_key);
    }

    BIO_free_all(bp_public);
    BIO_free_all(bp_private);
    RSA_free(rsa);
    BN_free(bne);

    //free(pri_key);
    //free(pub_key);
    if (ret == 1) {
        ret = 0;
    } else {
        ret = -1;
    }
    return ret;
}

////////////////////////////////////////////////////////////////////////////
// rsa for NSData
// if sucess, return the lenth of encrypted buffer
int rsa_encrypt_nsdata(NSData* pubKey, NSData* plainData, int plainDataSize,
                      NSData** encData) {
    int len = 0;
    RSA *rsa = NULL;
    
    unsigned char* pPubKey = (unsigned char*) [pubKey bytes];
    unsigned char* pPlainData = (unsigned char*) [plainData bytes];
    unsigned char* pEncData = NULL;
    
    bool result = load_public_key(&rsa, pPubKey);
    if (!result) {
        goto L_EXIT;
    }

    len = rsa_encrypt(rsa, pPlainData, plainDataSize, &pEncData);
    *encData = [NSData dataWithBytes:pEncData length:len];
    
    L_EXIT:

    return len;
}

// if sucess, return the lenth of decrypted buffer
int rsa_decrypt_nsdata(NSData* priKey, NSData* encData, int encDataSize,
                      NSData **plainData) {
    int len = 0;
    RSA *rsa = NULL;
    
    unsigned char* pPriKey = (unsigned char*) [priKey bytes];
    unsigned char* pEncData = (unsigned char*) [encData bytes];
    unsigned char* pPlainData = NULL;
    
    bool result = load_private_key(&rsa, pPriKey);
    if (!result) {
        goto L_EXIT;
    }

    len = rsa_decrypt(rsa, pEncData, encDataSize, &pPlainData);
    *plainData = [NSData dataWithBytes:pPlainData length:len];

    L_EXIT:

    return len;
}
