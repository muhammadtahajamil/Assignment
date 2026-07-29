#ifndef OPENSSLBASE64HELPER_H
#define OPENSSLBASE64HELPER_H

#include <string>
#include <vector>

class OpenSSL_Base64Helper
{
private:
    OpenSSL_Base64Helper() = delete;

public:
    static bool Encode(const std::vector<unsigned char>& data, std::string& output);
    static bool Decode(const std::string& data, std::vector<unsigned char>& output);
};

#endif
