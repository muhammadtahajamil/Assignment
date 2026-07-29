#ifndef OPENSSLAESHELPER_H
#define OPENSSLAESHELPER_H

#include <string>
#include <vector>

class OpenSSL_AESHelper
{
private:
    OpenSSL_AESHelper() = delete;

public:
    static bool Encrypt(const std::vector<unsigned char>& key, const std::vector<unsigned char>& iv, const std::string& plaintext, std::vector<unsigned char>& ciphertext);
    static bool Encrypt(const std::vector<unsigned char>& key, const std::vector<unsigned char>& plaintext, std::vector<unsigned char>& ciphertext);

    static bool Decrypt(const std::vector<unsigned char>& key, const std::vector<unsigned char>& ciphertext, std::vector<unsigned char>& plaintext);
    static bool Decrypt(const std::vector<unsigned char>& key, const std::vector<unsigned char>& iv, const std::vector<unsigned char>& ciphertext, std::string& plaintext);
};

#endif
