#ifndef OPENSSLIVHELPER_H
#define OPENSSLIVHELPER_H

#include <vector>

class OpenSSL_IVHelper
{
private:
	OpenSSL_IVHelper() = delete;

public:
	static bool GenerateIV(std::vector<unsigned char>& iv);
};

#endif

