#ifndef OPENSSLHMACSHA256HELPER_H
#define OPENSSLHMACSHA256HELPER_H

#include <string>
#include <vector>

class OpenSSL_HMACSHA256Helper
{
private:
	OpenSSL_HMACSHA256Helper() = delete;

public:
	static bool ComputeHMACSHA256(const std::string& data, const std::string& key, std::string& output);
	static bool ComputeHMACSHA256(const std::vector<unsigned char>& data, const std::vector<unsigned char>& key, std::vector<unsigned char>& output);
};

#endif

