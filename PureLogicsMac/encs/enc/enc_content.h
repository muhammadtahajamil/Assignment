#ifndef enc_content_h
#define enc_content_h

#ifdef __cplusplus
extern "C" {
#endif

int contentEncrypt(NSData* aesKey, int aesKeyLen, NSData* srcData, int srcLength, NSData** dstData, int64_t blockNum);
int contentDecrypt(NSData* aesKey, int aesKeyLen, NSData* srcData, int srcLength, NSData** dstData, int64_t blockNum);

#ifdef __cplusplus
}
#endif

#endif /* enc_content_h */
