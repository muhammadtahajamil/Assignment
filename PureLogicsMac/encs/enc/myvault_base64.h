//
//  myvault_base64.h
//  iosvault
//
//  Created by admin on 8/1/21.
//

#ifndef myvault_base64_h
#define myvault_base64_h

int Encode(unsigned char* input, int length, unsigned char** outBuf);
int Decode(unsigned char* input, int length, unsigned char** outBuf);

int encode_base64_nsdata(NSData* inputData, int length, NSData** outBufData);
int decode_base64_nsdata(NSData* inputData, int length, NSData** outBufData);

#endif /* myvault_base64_h */
