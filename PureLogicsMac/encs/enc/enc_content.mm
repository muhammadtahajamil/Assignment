#import <Foundation/Foundation.h>
#import <OpenSSL/OpenSSL.h>
#import "enc_content.h"
#import <string>

/////////////////////////////////////////////////
//#define IV_SPEC "123456789012345"
#define IV_SPEC "6533224387995303"
#define BLOCK_SIZE 8192
////////////////////////////////////////////////
///


// Start: Advance declarations of the functions defined below in this file.
void longToBytesByBE(std::string &bytes, int64_t num);
void generateIv(const std::string &iv, const std::string &ivSeed, unsigned char* ivResult);

std::string contentEncrypt(const std::string fileAesKey, const std::string src, const int64_t blockNum);
std::string contentDecrypt(const std::string fileAesKey, const std::string fileEncData, const int64_t blockNum);

void blockEncrypt(const std::string fileAesKey, const std::string volumeIv, const std::string ivSeed, EVP_CIPHER_CTX* ctx, const std::string data, std::string& result);
void blockDecrypt(const std::string fileAesKey, const std::string volumeIv, const std::string ivSeed, EVP_CIPHER_CTX* ctx, const std::string data, std::string& result);

void streamEncrypt(const std::string fileAesKey, const std::string volumeIv, const std::string ivSeed, EVP_CIPHER_CTX* ctx, const std::string data, std::string& result);
void streamDecrypt(const std::string fileAesKey, const std::string volumeIv, const std::string ivSeed, EVP_CIPHER_CTX* ctx, const std::string data, std::string& result);
// End: Advance declarations of the functions defined below in this file.


// Start: utility functions
// Function to convert NSData to std::string
std::string convertNSDataToStdString(NSData *data) {
    if (!data) {
        return std::string();
    }
    const void *bytes = [data bytes];
    return std::string((const char *)bytes, [data length]);
}

// Function to convert std::string to NSData
NSData *convertStdStringToNSData(const std::string &str) {
    return [NSData dataWithBytes:str.data() length:str.size()];
}
// End: utility functions


// flipBytes
void flipBytes(const std::string src, std::string &dest) {
    dest.resize(src.size());

    size_t offset = 0;
    size_t bytesLeft = src.size();

    while (bytesLeft > 0) {
        size_t toFlip = bytesLeft > 64 ? 64 : bytesLeft;

        for (size_t i = 0; i < toFlip; i++)
            dest[offset + i] = src[offset + toFlip - i - 1];

        bytesLeft -= toFlip;
        offset += toFlip;
    }

}

/**
Unpack 64bit int to 8byte string.
*/
void longToBytesByBE(std::string &bytes, int64_t num)
{
    bytes.resize(8);
    bytes[0] = (num >> 56) & 0xFF;
    bytes[1] = (num >> 48) & 0xFF;
    bytes[2] = (num >> 40) & 0xFF;
    bytes[3] = (num >> 32) & 0xFF;
    bytes[4] = (num >> 24) & 0xFF;
    bytes[5] = (num >> 16) & 0xFF;
    bytes[6] = (num >> 8) & 0xFF;
    bytes[7] = num & 0xFF;
}

/**
Pack 8byte string to 64bit int.
*/
inline int64_t bytesToLongByBE(const std::string &bytes) {
    int64_t num = (int64_t)bytes[7] & 0xFF;
    num |= ((int64_t)bytes[6] & 0xFF) << 8;
    num |= ((int64_t)bytes[5] & 0xFF) << 16;
    num |= ((int64_t)bytes[4] & 0xFF) << 24;
    num |= ((int64_t)bytes[3] & 0xFF) << 32;
    num |= ((int64_t)bytes[2] & 0xFF) << 40;
    num |= ((int64_t)bytes[1] & 0xFF) << 48;
    num |= ((int64_t)bytes[0] & 0xFF) << 56;
    return num;
}

/**
Unpack 32bit int to 4byte string.
*/
inline void intToBytesByBE(std::string &bytes, int32_t num) {
    bytes.resize(4);
    bytes[0] = (num >> 24) & 0xFF;
    bytes[1] = (num >> 16) & 0xFF;
    bytes[2] = (num >> 8) & 0xFF;
    bytes[3] = num & 0xFF;
}

/**
Pack 4byte string to 32bit int.
*/
inline int32_t bytesToIntByBE(const std::string &bytes) {
    int32_t num = (int32_t)bytes[3] & 0xFF;
    num |= ((int32_t)bytes[2] & 0xFF) << 8;
    num |= ((int32_t)bytes[1] & 0xFF) << 16;
    num |= ((int32_t)bytes[0] & 0xFF) << 24;
    return num;
}

/**
Add one to 4byte or 8byte initialization vector.
*/
inline void incrementIvSeedByOne(const std::string ivSeed, std::string &ivSeedPlusOne) {
    if (ivSeed.size() == 4) {
        int32_t num = bytesToIntByBE(ivSeed);
        ++num;
        intToBytesByBE(ivSeedPlusOne, num);
    }
    else {
        int64_t num = bytesToLongByBE(ivSeed);
        ++num;
        longToBytesByBE(ivSeedPlusOne, num);
    }
}

/**
Generate initialization vector.
*/
void generateIv(const std::string &iv, const std::string &ivSeed, unsigned char* ivResult)
{
    std::string concat;
    concat.insert(concat.begin(), iv.begin(), iv.end());
    concat.resize(iv.size() + 8);

    if (ivSeed.size() == 4) {
        for (int i = 0; i < 4; ++i) {
            concat[iv.size() + i] = ivSeed[3 - i];
        }
        for (int i = 4; i < 8; ++i) {
            concat[iv.size() + i] = 0;
        }
    }
    else {
        for (int i = 0; i < 8; ++i) {
            concat[iv.size() + i] = ivSeed[7 - i];
        }
    }

    std::string key = "12345678901234567890123456789012";
    unsigned char d[SHA_DIGEST_LENGTH]; // Buffer for the HMAC result
    size_t dlen = SHA_DIGEST_LENGTH;

    // NOTE:: No error handling done below!

    // Create an EVP_MAC context
    EVP_MAC *mac = EVP_MAC_fetch(NULL, "HMAC", NULL);
    EVP_MAC_CTX *ctx = EVP_MAC_CTX_new(mac);

    // Prepare key parameter
    OSSL_PARAM params[] = {
            OSSL_PARAM_construct_utf8_string("digest", const_cast<char *>("SHA1"), 0),
            OSSL_PARAM_construct_end()
    };

    // Initialize HMAC context with key and parameters
    EVP_MAC_init(ctx, reinterpret_cast<const unsigned char *>(key.data()), key.length(), params);

    // Update HMAC with data
    EVP_MAC_update(ctx, reinterpret_cast<const unsigned char *>(concat.data()), concat.size());

    // Finalize HMAC and get result
    EVP_MAC_final(ctx, d, &dlen, sizeof(d));

    // Clean up
    EVP_MAC_CTX_free(ctx);
    EVP_MAC_free(mac);

    // Copy the first 16 bytes of the HMAC result to ivResult
    memcpy(ivResult, d, 16);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//
int contentEncrypt(NSData* aesKey, int aesKeyLen, NSData* srcData, int srcLength, NSData** dstData, int64_t blockNum)
{
    if (aesKey.length != 32 || aesKey.length != aesKeyLen) {
        return -1;
    }
     
    if (srcData.length == 0 || srcData.length != srcLength) {
        return -2;
    }
    
    std::string fileAesKey = convertNSDataToStdString(aesKey);
    std::string src = convertNSDataToStdString(srcData);

    const int64_t fileIv = -6148914691236517206;
    const int64_t blockIv = blockNum ^ fileIv;

    std::string ivSeed;
    longToBytesByBE(ivSeed, blockIv);

    std::string volumeIv = "6533224387995303";

    // Create and initialize the context
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();

    std::string fileEncData = "";

    if (src.size() == BLOCK_SIZE) {
        blockEncrypt(fileAesKey, volumeIv, ivSeed, ctx, src, fileEncData);
    } else {
        streamEncrypt(fileAesKey, volumeIv, ivSeed, ctx, src, fileEncData);
    }

    // Clean up
    EVP_CIPHER_CTX_free(ctx);
    
    if (fileEncData.length() > 0) {
        *dstData = convertStdStringToNSData(fileEncData);
    }

    return (int)fileEncData.length();
}

int contentDecrypt(NSData* aesKey, int aesKeyLen, NSData* srcData, int srcLength, NSData** dstData, int64_t blockNum)
{
    if (aesKey.length != 32 || aesKey.length != aesKeyLen) {
        return -1;
    }
     
    if (srcData.length == 0 || srcData.length != srcLength) {
        return -2;
    }
    
    std::string fileAesKey = convertNSDataToStdString(aesKey);
    std::string fileEncData = convertNSDataToStdString(srcData);

    const int64_t fileIv = -6148914691236517206;
    const int64_t blockIv = blockNum ^ fileIv;

    std::string ivSeed;
    longToBytesByBE(ivSeed, blockIv);

    std::string volumeIv = "6533224387995303";

    // Create and initialize the context
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();

    std::string fileDecData = "";

    if (fileEncData.size() == BLOCK_SIZE) {
        blockDecrypt(fileAesKey, volumeIv, ivSeed, ctx, fileEncData, fileDecData);
    } else {
        streamDecrypt(fileAesKey, volumeIv, ivSeed, ctx, fileEncData, fileDecData);
    }

    // Clean up
    EVP_CIPHER_CTX_free(ctx);
    
    if (fileDecData.length() > 0) {
        *dstData = convertStdStringToNSData(fileDecData);
    }

    return (int)fileDecData.length();
}

/////////////////////////////////////////////////////
//
void blockEncrypt(const std::string fileAesKey, const std::string volumeIv, const std::string ivSeed, EVP_CIPHER_CTX* ctx, const std::string data, std::string& result)
{
    unsigned char ivSpec[16] = { 0 };
    generateIv(volumeIv, ivSeed, ivSpec);

    int initBufLen = data.length() + 16;
    unsigned char* encBuf = new unsigned char[initBufLen];
    int encBufLen = 0;
    int tempLen = 0;
    memset(encBuf, 0, initBufLen);

    {
        //lock_guard<decltype(cipherLock)> lock(cipherLock);
        EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, (unsigned char*)fileAesKey.c_str(), (unsigned char*)ivSpec);
        EVP_CIPHER_CTX_set_padding(ctx, 0);
        EVP_EncryptUpdate(ctx, encBuf, &encBufLen,(unsigned char*)data.c_str(), (int)data.length());
        EVP_EncryptFinal_ex(ctx, encBuf + encBufLen, &tempLen);
        encBufLen += tempLen;
    }

    std::string tempStr = std::string((char*)encBuf, encBufLen);
    result.clear();
    result.append(tempStr);

    if (encBuf != NULL) {
        delete[] encBuf;
    }
}

/////////////////////////////////////////////////////
//
void blockDecrypt(const std::string fileAesKey, const std::string volumeIv, const std::string ivSeed, EVP_CIPHER_CTX* ctx, const std::string data, std::string& result)
{
    unsigned char ivSpec[16] = { 0 };
    generateIv(volumeIv, ivSeed, ivSpec);

    int initBufLen = data.length() + 16;
    unsigned char* decBuf = new unsigned char[initBufLen];
    int decBufLen = 0;
    int tempLen = 0;
    memset(decBuf, 0, initBufLen);

    {
        //lock_guard<decltype(cipherLock)> lock(cipherLock);
        EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, (unsigned char*)fileAesKey.c_str(), (unsigned char*)ivSpec);
        EVP_CIPHER_CTX_set_padding(ctx, 0);
        EVP_DecryptUpdate(ctx, decBuf, &decBufLen, (unsigned char*)data.c_str(), (int)data.length());
        EVP_DecryptFinal_ex(ctx, decBuf + decBufLen, &tempLen);
        decBufLen += tempLen;
    }

    std::string tempStr = std::string((char*)decBuf, decBufLen);
    result.clear();
    result.append(tempStr);

    if (decBuf != NULL) {
        delete[] decBuf;
    }
}

void streamEncrypt(const std::string fileAesKey, const std::string volumeIv, const std::string ivSeed, EVP_CIPHER_CTX* ctx, const std::string data, std::string& result)
{
    // AES / CFB / NoPadding
    std::string ivSeedPlusOne;
    incrementIvSeedByOne(ivSeed, ivSeedPlusOne);

    int initBufLen = data.length() + 16;
    unsigned char* encBuf = new unsigned char[initBufLen];
    memset(encBuf, 0, initBufLen);

    std::string firstEncResult;
    {
        std::string buf = data;

        // suffleBytes
        for (int i = 0; i < buf.size() - 1; ++i) {
            buf[i + 1] ^= buf[i];
        }

        unsigned char ivSpec[16] = { 0 };
        generateIv(volumeIv, ivSeed, ivSpec);

        int encBufLen = 0;
        int tempLen = 0;
        {
            //lock_guard<decltype(cipherLock)> lock(cipherLock);
            EVP_EncryptInit_ex(ctx, EVP_aes_256_cfb(), NULL, (unsigned char*)fileAesKey.c_str(), (unsigned char*)ivSpec);
            EVP_CIPHER_CTX_set_padding(ctx, 0);
            EVP_EncryptUpdate(ctx, encBuf, &encBufLen, (unsigned char*)buf.c_str(), (int)buf.length());
            EVP_EncryptFinal_ex(ctx, encBuf + encBufLen, &tempLen);
            encBufLen += tempLen;
            firstEncResult = std::string((char*)encBuf, encBufLen);
        }
    }

    //flip  bytes
    std::string flipBytesResult;
    flipBytes(firstEncResult, flipBytesResult);

    // suffleBytes
    for (int i = 0; i < flipBytesResult.size() - 1; ++i) {
        flipBytesResult[i + 1] ^= flipBytesResult[i];
    }

    {
        unsigned char ivSpec[16] = { 0 };
        generateIv(volumeIv, ivSeedPlusOne, ivSpec);

        int encBufLen = 0;
        int tempLen = 0;

        {
            //lock_guard<decltype(cipherLock)> lock(cipherLock);
            EVP_EncryptInit_ex(ctx, EVP_aes_256_cfb(), NULL, (unsigned char*)fileAesKey.c_str(), (unsigned char*)ivSpec);
            EVP_CIPHER_CTX_set_padding(ctx, 0);
            EVP_EncryptUpdate(ctx, encBuf, &encBufLen, (unsigned char*)flipBytesResult.c_str(), (int)flipBytesResult.length());
            EVP_EncryptFinal_ex(ctx, encBuf + encBufLen, &tempLen);
            encBufLen += tempLen;


            std::string tempStr = std::string((char*)encBuf, encBufLen);
            result.clear();
            result.append(tempStr);
        }
    }

    if (encBuf != NULL) {
        delete[] encBuf;
    }
}

void streamDecrypt(const std::string fileAesKey, const std::string volumeIv, const std::string ivSeed, EVP_CIPHER_CTX* ctx, const std::string data, std::string& result)
{
    int initBufLen = data.length() + 16;
    unsigned char* decBuf = new unsigned char[initBufLen];
    memset(decBuf, 0, initBufLen);

    // AES / CFB / NoPadding
    std::string firstDecResult;
    {
        std::string ivSeedPlusOne;
        incrementIvSeedByOne(ivSeed, ivSeedPlusOne);

        unsigned char ivSpec[16] = { 0 };
        generateIv(volumeIv, ivSeedPlusOne, ivSpec);

        int decBufLen = 0;
        int tempLen = 0;

        {
            //lock_guard<decltype(cipherLock)> lock(cipherLock);
            EVP_DecryptInit_ex(ctx, EVP_aes_256_cfb(), NULL, (unsigned char*)fileAesKey.c_str(), ivSpec);
            EVP_CIPHER_CTX_set_padding(ctx, 0);
            EVP_DecryptUpdate(ctx, decBuf, &decBufLen, (unsigned char*)data.c_str(), (int)data.length());
            EVP_DecryptFinal_ex(ctx, decBuf + decBufLen, &tempLen);
            decBufLen += tempLen;

            firstDecResult = std::string((char*)decBuf, decBufLen);
        }
    }

    // unsuffleBytes
    for (size_t i = (firstDecResult.size() - 1); i > 0; i--) {
        firstDecResult[i] ^= firstDecResult[i - 1];
    }

    //flip  bytes
    std::string flipBytesResult;
    flipBytes(firstDecResult, flipBytesResult);

    {
        unsigned char ivSpec[16] = { 0 };
        generateIv(volumeIv, ivSeed, ivSpec);

        int decBufLen = 0;
        int tempLen = 0;
        {
            //lock_guard<decltype(cipherLock)> lock(cipherLock);
            EVP_DecryptInit_ex(ctx, EVP_aes_256_cfb(), NULL, (unsigned char*)fileAesKey.c_str(), (unsigned char*)ivSpec);
            EVP_CIPHER_CTX_set_padding(ctx, 0);
            EVP_DecryptUpdate(ctx, decBuf, &decBufLen, (unsigned char*)flipBytesResult.c_str(), (int)flipBytesResult.length());
            EVP_DecryptFinal_ex(ctx, decBuf + decBufLen, &tempLen);
            decBufLen += tempLen;

            std::string tempStr = std::string((char*)decBuf, decBufLen);
            result.clear();
            result.append(tempStr);
        }
    }

    // unsuffleBytes
    for (size_t i = (result.size() - 1); i > 0; i--) {
        result[i] ^= result[i - 1];
    }

    if (decBuf != NULL) {
        delete[] decBuf;
    }
}

