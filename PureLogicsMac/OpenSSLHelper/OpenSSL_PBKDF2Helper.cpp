#include "OpenSSL_PBKDF2Helper.h"
#include <openssl/evp.h>
#include <openssl/rand.h>

bool OpenSSL_PBKDF2Helper::Compute_PBKDF2_HMAC_SHA512(
    const std::vector<unsigned char>& password,
    const std::vector<unsigned char>& salt,
    const int iterations,
    const int derivedBytesCount,
    std::vector<unsigned char>& derivedBytes)
{
    derivedBytes.clear();
    derivedBytes.resize(derivedBytesCount);

    // Hash the password using PBKDF2 HMAC-SHA512
    if (PKCS5_PBKDF2_HMAC(
        reinterpret_cast<const char*>(password.data()), 
        password.size(),
        salt.data(), 
        salt.size(), 
        iterations, 
        EVP_sha512(), 
        derivedBytes.size(), 
        derivedBytes.data()) == 0)
    {
        // Error hashing password.
        return false;
    }

    return true;
}