#include "OpenSSL_Helper.h"

#include "OpenSSL_Base64Helper.h"
#include "OpenSSL_RSAHelper.h"
#include "OpenSSL_AESHelper.h"

bool OpenSSL_Helper::RsaEncryptBase64Encode(
	const std::vector<unsigned char>& input, 
	const std::vector<unsigned char>& derEncodedPublicKey, 
	std::string& output)
{
	std::vector<unsigned char> encryptedInput;
	if (!OpenSSL_RSAHelper::Encrypt(input, derEncodedPublicKey, encryptedInput))
	{
		return false;
	}

	if (!OpenSSL_Base64Helper::Encode(encryptedInput, output))
	{
		return false;
	}

	return true;
}

bool OpenSSL_Helper::Base64DecodeRsaDecrypt(const std::string& input, const std::vector<unsigned char>& derEncodedPrivateKey, std::vector<unsigned char>& output)
{
	std::vector<unsigned char> base64DecodedInput;
	if (!OpenSSL_Base64Helper::Decode(input, base64DecodedInput))
	{
		return false;
	}

	if (!OpenSSL_RSAHelper::Decrypt(base64DecodedInput, derEncodedPrivateKey, output))
	{
		return false;
	}

	return true;
}

bool OpenSSL_Helper::AesEncryptBase64Encode(
	const std::vector<unsigned char>& input, 
	const std::vector<unsigned char>& aesKey, 
	std::string& output)
{
	std::vector<unsigned char> encryptedInput;
	if (!OpenSSL_AESHelper::Encrypt(aesKey, input, encryptedInput))
	{
		return false;
	}

	if (!OpenSSL_Base64Helper::Encode(encryptedInput, output))
	{
		return false;
	}

	return true;
}

bool OpenSSL_Helper::Base64DecodeAesDecrypt(
	const std::string& input, 
	const std::vector<unsigned char>& aesKey, 
	std::vector<unsigned char>& output)
{
	std::vector<unsigned char> base64DecodedInput;
	if (!OpenSSL_Base64Helper::Decode(input, base64DecodedInput))
	{
		return false;
	}
	
	if (!OpenSSL_AESHelper::Decrypt(aesKey, base64DecodedInput, output))
	{
		return false;
	}

	return true;
}
