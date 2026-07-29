//
//  myvault_base64.m
//  iosvault
//
//  Created by admin on 2/11/21.
//

#import <Foundation/Foundation.h>
#import <OpenSSL/OpenSSL.h>

int leftTrim(char* pBuf, int length) {
    int ret = 0;
    for (int i = 0; i < length; i++) {
        if (pBuf[i] == ' ') {
            ret = i;
        }
        else {
            break;
        }
    }

    return ret;
}

int rightTrim(char* pBuf, int length) {
    int ret = 0;
    for (int i = length; i > 0; i--) {
        if (pBuf[i] == ' ') {
            ret = i;
        }
        else {
            break;
        }
    }

    return ret;
}

int Encode(unsigned char* input, int length, unsigned char** outBuf) {
    BIO* bmem, * b64;
    BUF_MEM* bptr;

    b64 = BIO_new(BIO_f_base64());
    bmem = BIO_new(BIO_s_mem());
    //BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    b64 = BIO_push(b64, bmem);
    int encLen = BIO_write(b64, input, length);
    BIO_flush(b64);
    BIO_get_mem_ptr(b64, &bptr);

    //char* buff = (char*)malloc(bptr->length);
    encLen = (int)bptr->length;
    char* buff = malloc(encLen + 1);
    memset(buff, 0, encLen+1);
    memcpy(buff, bptr->data, encLen);
    buff[encLen] = 0;

    BIO_free_all(b64);

    *outBuf = (unsigned char*)buff;

    return encLen;
}

int Decode(unsigned char* input, int length, unsigned char** outBuf) {
    BIO* bio, * b64;
    //unsigned char* buffer = (unsigned char*)malloc(length);
    unsigned char* buffer = malloc(length);
    memset(buffer, 0, length);

    b64 = BIO_new(BIO_f_base64());
    bio = BIO_new_mem_buf(input, length);
    //BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL); //Do not use newlines to flush buffer
    bio = BIO_push(b64, bio);

    //
    int encLen = BIO_read(bio, (char*)buffer, length);
    //assert(*length == decodeLen); //length should equal decodeLen, else something went horribly wrong
    buffer[encLen] = '\0';
    *outBuf = buffer;

    BIO_free_all(bio);

    return encLen;

}

int encode_base64_nsdata(NSData* inputData, int length, NSData** outBufData) {
    unsigned char* input = (unsigned char*) [inputData bytes];
        
    BIO* bmem, * b64;
    BUF_MEM* bptr;

    b64 = BIO_new(BIO_f_base64());
    bmem = BIO_new(BIO_s_mem());
    //BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    b64 = BIO_push(b64, bmem);
    int encLen = BIO_write(b64, input, length);
    BIO_flush(b64);
    BIO_get_mem_ptr(b64, &bptr);

    //char* buff = (char*)malloc(bptr->length);
    encLen = (int)bptr->length;
    char* buff = malloc(encLen + 1);
    memset(buff, 0, encLen+1);
    memcpy(buff, bptr->data, encLen);
    buff[encLen] = 0;

    BIO_free_all(b64);
    
    //*outBuf = (unsigned char*)buff;
    *outBufData = [NSData dataWithBytes:buff length:encLen];
    return encLen;
}

int decode_base64_nsdata(NSData* inputData, int length, NSData** outBufData) {
    unsigned char* input = (unsigned char*) [inputData bytes];
        
    BIO* bio, * b64;
    //unsigned char* buffer = (unsigned char*)malloc(length);
    unsigned char* buffer = malloc(length);
    memset(buffer, 0, length);

    b64 = BIO_new(BIO_f_base64());
    bio = BIO_new_mem_buf(input, length);
    //BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL); //Do not use newlines to flush buffer
    bio = BIO_push(b64, bio);

    //
    int encLen = BIO_read(bio, (char*)buffer, length);
    //assert(*length == decodeLen); //length should equal decodeLen, else something went horribly wrong
    buffer[encLen] = '\0';
    //*outBuf = (unsigned char*)buff;
    *outBufData = [NSData dataWithBytes:buffer length:encLen];

    BIO_free_all(bio);

    return encLen;
}
