#ifndef enc_filename_h
#define enc_filename_h

#ifdef __cplusplus
extern "C" {
#endif

int decodeBase64FileName(NSData* srcData, NSData** dstData);
int encodeBase64FileName(NSData* srcData, NSData** dstData);

#ifdef __cplusplus
}
#endif

#endif /* enc_filename_h */
