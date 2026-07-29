#ifndef OPENSSLRSAHELPER_H
#define OPENSSLRSAHELPER_H

#include <vector>
#include <string>

class OpenSSL_RSAHelper
{
private:
    OpenSSL_RSAHelper() = delete;

public:
    static bool GenerateKeys(std::vector<unsigned char>& derEncodedPublicKey, std::vector<unsigned char>& derEncodedPrivateKey);
    static bool ValidateKeys(const std::vector<uint8_t>& derPublicKey, const std::vector<uint8_t>& derPrivateKey);

    static bool Encrypt(const std::vector<unsigned char>& data, const std::vector<unsigned char>& derEncodedPublicKey, std::vector<unsigned char>& encryptedData);
    static bool Decrypt(const std::vector<unsigned char>& encryptedData, const std::vector<unsigned char>& derEncodedPrivateKey, std::vector<unsigned char>& decryptedData);
};

#endif
