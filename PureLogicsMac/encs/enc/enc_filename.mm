//
//  enc_filename.m
//  FolderLockAdvanced
//
//  Created by MacBook on 24/07/2024.
//  Copyright © 2024 minimac2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "enc_filename.h"
#import <string>


static const unsigned char ALPHABET[] = ",-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
static int base64Lookup[256];
static bool isInitialized = false;


// Start: utility functions
// Function to convert NSData to std::string
std::string convertNSDataToString(NSData *data) {
    if (!data) {
        return std::string();
    }
    const void *bytes = [data bytes];
    return std::string((const char *)bytes, [data length]);
}

// Function to convert std::string to NSData
NSData *convertStringToNSData(const std::string &str) {
    return [NSData dataWithBytes:str.data() length:str.size()];
}
// End: utility functions


void InitializeDecodingLookupArray(unsigned int base, bool caseInsensitive)
{
    std::fill(base64Lookup, base64Lookup+256, -1);

    for (unsigned int i=0; i<base; i++)
    {
        // Debug asserts for 'lookup[alphabet[i]] == -1' removed because the self tests
        // have unusal tests that try to break the encoders and decoders. Tests include
        // a string of the same characters. I.,e., a string of stars like '********...'.
        if (caseInsensitive && isalpha(ALPHABET[i]))
        {
            base64Lookup[toupper(ALPHABET[i])] = i;
            base64Lookup[tolower(ALPHABET[i])] = i;
        }
        else
        {
            base64Lookup[ALPHABET[i]] = i;
        }
    }
}

int decodeBase64FileName(NSData* srcData, NSData** dstData) {
    
    std::string encodedName = convertNSDataToString(srcData);
    
    if (!isInitialized) {
       InitializeDecodingLookupArray(64, false);
    }
    
    std::string in;
    in.resize(encodedName.size());
    for (size_t i = 0; i < encodedName.size(); i++) {
        if (base64Lookup[encodedName[i]] == -1) {
            return -1;
        }
        in[i] = (char)base64Lookup[encodedName[i]];
    }

    std::string decodedName;
    size_t srcIdx = 0;
    int workBits = 0;
    unsigned int work = 0;
    while (srcIdx < in.size()) {
        work |= in[srcIdx++] << workBits;
        workBits += 6;

        while (workBits >= 8) {
            decodedName.append(1, work & 0xff);
            work >>= 8;
            workBits -= 8;
        }
    }
    
    *dstData = convertStringToNSData(decodedName);
    
    return 0;
}

int encodeBase64FileName(NSData* srcData, NSData** dstData) {
    
    std::string in = convertNSDataToString(srcData);
    std::string out;

    size_t outSize = in.size() * 8 / 6 + ((in.size() * 8 % 6) == 0 ? 0 : 1);
    long mask = (1 << 6) - 1;
    int workingBits = 0;
    long work = 0;
    for (int i = 0; i < in.size(); ++i) {
        int unsignedIntValue = in[i] & 0xFF;
        work |= unsignedIntValue << workingBits;

        workingBits += 8;

        while (workingBits > 6) {
            out.append(1, work & (mask & 0xFF));
            work >>= 6;
            workingBits -= 6;
        }
    }

    if (workingBits > 0) {
        out.append(1, work & (mask & 0xFF));
    }

    for (size_t i = 0; i < outSize; ++i) {
        size_t ii = out.size() - i - 1;
        out[ii] = ALPHABET[out[ii]];
    }
    
    *dstData = convertStringToNSData(out);

    return 0;
}
