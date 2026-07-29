#ifndef OPENSSLPBKDF2HELPER_H
#define OPENSSLPBKDF2HELPER_H

#include <string>
#include <vector>

class OpenSSL_PBKDF2Helper
{
private:
    OpenSSL_PBKDF2Helper() = delete;

public:
    static bool Compute_PBKDF2_HMAC_SHA512(
        const std::vector<unsigned char>& password,
        const std::vector<unsigned char>& salt,
        const int iterations,
        const int derivedBytesCount, 
        std::vector<unsigned char>& derivedBytes
    );
};

#endif