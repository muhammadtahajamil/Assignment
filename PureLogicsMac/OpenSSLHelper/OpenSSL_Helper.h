#ifndef OPENSSLHELPER_H
#define OPENSSLHELPER_H

#include <string>
#include <vector>

class OpenSSL_Helper
{
private:
	OpenSSL_Helper() = delete;

public:
	static bool RsaEncryptBase64Encode(const std::vector<unsigned char>& input, const std::vector<unsigned char>& derEncodedPublicKey, std::string& output);
	static bool Base64DecodeRsaDecrypt(const std::string& input, const std::vector<unsigned char>& derEncodedPrivateKey, std::vector<unsigned char>& output);

	static bool AesEncryptBase64Encode(const std::vector<unsigned char>& input, const std::vector<unsigned char>& aesKey, std::string& output);
	static bool Base64DecodeAesDecrypt(const std::string& input, const std::vector<unsigned char>& aesKey, std::vector<unsigned char>& output);
};

#endif

