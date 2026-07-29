#include "OpenSSL_SHA256Helper.h"

#include <openssl/sha.h>

// Function to compute SHA256 hash from a std::vector<unsigned char> using OpenSSL's SHA256 function
std::vector<unsigned char> OpenSSL_SHA256Helper::ComputeSHA256(const std::vector<unsigned char>& input)
{
    std::vector<unsigned char> hash(SHA256_DIGEST_LENGTH); // Resize the output vector to hold the SHA256 hash

    // Compute the SHA256 hash
    SHA256(input.data(), input.size(), hash.data());

    return hash; // Return the computed hash
}

std::vector<unsigned char> OpenSSL_SHA256Helper::ComputeAESKeySeedDataHash(const std::string& emailAddress, const std::vector<unsigned char>& passwordSha256Hash, const std::vector<unsigned char>& derEncodedPrivateKeySha256Hash)
{
    const size_t aesKeySeedDataSize = emailAddress.size() + SHA256_DIGEST_LENGTH + SHA256_DIGEST_LENGTH;

    std::vector<unsigned char> aesKeySeedData;
    aesKeySeedData.reserve(aesKeySeedDataSize);

    aesKeySeedData.insert(aesKeySeedData.end(), emailAddress.begin(), emailAddress.end());

    const std::vector<unsigned char> passwordHash = OpenSSL_SHA256Helper::ComputeSHA256(passwordSha256Hash);
    aesKeySeedData.insert(aesKeySeedData.end(), passwordHash.begin(), passwordHash.end());

    const std::vector<unsigned char> privateKeyHash = OpenSSL_SHA256Helper::ComputeSHA256(derEncodedPrivateKeySha256Hash);
    aesKeySeedData.insert(aesKeySeedData.end(), privateKeyHash.begin(), privateKeyHash.end());

    return OpenSSL_SHA256Helper::ComputeSHA256(aesKeySeedData);
}

