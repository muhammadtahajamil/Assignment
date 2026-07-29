#ifndef OPENSSLSHA256HELPER_H
#define OPENSSLSHA256HELPER_H

#include <vector>
#include <string>

class OpenSSL_SHA256Helper
{
private:
    OpenSSL_SHA256Helper() = delete;

public:
    static std::vector<unsigned char> ComputeSHA256(const std::vector<unsigned char>& input);
    static std::vector<unsigned char> ComputeAESKeySeedDataHash(const std::string& emailAddress, const std::vector<unsigned char>& passwordSha256Hash, const std::vector<unsigned char>& derEncodedPrivateKeySha256Hash);
};

#endif
