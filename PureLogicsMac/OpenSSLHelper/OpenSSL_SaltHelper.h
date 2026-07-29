#ifndef OPENSSLSALTHELPER_H
#define OPENSSLSALTHELPER_H

#include <vector>

class OpenSSL_SaltHelper
{
private:
	OpenSSL_SaltHelper() = delete;

public:
	static bool GenerateSalt(const unsigned int size, std::vector<unsigned char>& salt);
};

#endif