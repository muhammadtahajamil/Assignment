#ifndef OPENSSLAESKEYHELPER_H
#define OPENSSLAESKEYHELPER_H

#include <vector>
#include <string>

class OpenSSL_AESKeyHelper
{
private:
	OpenSSL_AESKeyHelper() = delete;

public:
	static bool GenerateAes256Key(std::vector<unsigned char>& aes256Key);
};

#endif

