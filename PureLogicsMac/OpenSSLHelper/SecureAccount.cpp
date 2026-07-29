#include "SecureAccount.h"

#include "OpenSSL_AESHelper.h"
#include "OpenSSL_Base64Helper.h"
#include "OpenSSL_HMACSHA256Helper.h"
#include "OpenSSL_IVHelper.h"
#include "OpenSSL_PBKDF2Helper.h"
#include "OpenSSL_RSAHelper.h"
#include "OpenSSL_SaltHelper.h"
#include "OpenSSL_SHA256Helper.h"
#include "OpenSSL_Helper.h"

#include <RapidJSON/document.h>
#include <RapidJSON/stringbuffer.h>
#include <RapidJSON/writer.h>

bool SecureAccount::Create(
    const std::vector<unsigned char>& password,
    std::vector<unsigned char>& derEncodedPublicKey,
    std::vector<unsigned char>& derEncodedPrivateKey,
    std::string& base64DerEncodedPublicKey,
    const int& privateKeyKdfIterations,
    std::string& base64EncodedPrivateKeySalt,
    std::string& base64EncodedSecurePrivateKey,
    const int& passwordHashKdfIterations,
    std::string& base64EncodedPasswordHashSalt,
    std::string& base64EncodedPasswordHash)
{
    std::vector<unsigned char> privateKeySalt;
    if (!OpenSSL_SaltHelper::GenerateSalt(24, privateKeySalt))
    {
        return false;
    }

    if (!OpenSSL_Base64Helper::Encode(privateKeySalt, base64EncodedPrivateKeySalt))
    {
        return false;
    }

    std::vector<unsigned char> derivedBytes; // [32 Bytes AES Key][32 Bytes HMAC Key]
    if (!OpenSSL_PBKDF2Helper::Compute_PBKDF2_HMAC_SHA512(password, privateKeySalt, privateKeyKdfIterations, 64, derivedBytes))
    {
        return false;
    }

    std::vector<unsigned char> aeskey(derivedBytes.begin(), derivedBytes.begin() + 32);
    std::vector<unsigned char> hmacKey(derivedBytes.begin() + 32, derivedBytes.end());

    std::vector<unsigned char> aesIv;
    if (!OpenSSL_IVHelper::GenerateIV(aesIv))
    {
        return false;
    }

    if (!OpenSSL_RSAHelper::GenerateKeys(derEncodedPublicKey, derEncodedPrivateKey))
    {
        return false;
    }

    if (!OpenSSL_Base64Helper::Encode(derEncodedPublicKey, base64DerEncodedPublicKey))
    {
        return false;
    }

    std::string base64DerEncodedPrivateKey;
    if (!OpenSSL_Base64Helper::Encode(derEncodedPrivateKey, base64DerEncodedPrivateKey))
    {
        return false;
    }

    std::vector<unsigned char> encryptedPrivateKey;
    if (!OpenSSL_AESHelper::Encrypt(aeskey, aesIv, base64DerEncodedPrivateKey, encryptedPrivateKey))
    {
        return false;
    }

    std::vector<unsigned char> encryptedPrivateKeyHmacSha256;
    if (!OpenSSL_HMACSHA256Helper::ComputeHMACSHA256(encryptedPrivateKey, hmacKey, encryptedPrivateKeyHmacSha256))
    {
        return false;
    }

    std::vector<unsigned char> securePrivateKey;
    // Reserve enough space for all elements to improve performance
    securePrivateKey.reserve(aesIv.size() + encryptedPrivateKeyHmacSha256.size() + encryptedPrivateKey.size());
    // First insert iv at the beginning of securePrivateKey
    securePrivateKey.insert(securePrivateKey.end(), aesIv.begin(), aesIv.end());
    // Next insert hmac of encrypted private key
    securePrivateKey.insert(securePrivateKey.end(), encryptedPrivateKeyHmacSha256.begin(), encryptedPrivateKeyHmacSha256.end());
    // Next insert encrypted private key
    securePrivateKey.insert(securePrivateKey.end(), encryptedPrivateKey.begin(), encryptedPrivateKey.end());

    if (!OpenSSL_Base64Helper::Encode(securePrivateKey, base64EncodedSecurePrivateKey))
    {
        return false;
    }

    std::vector<unsigned char> passwordHashSalt;
    if (!OpenSSL_SaltHelper::GenerateSalt(24, passwordHashSalt))
    {
        return false;
    }

    if (!OpenSSL_Base64Helper::Encode(passwordHashSalt, base64EncodedPasswordHashSalt))
    {
        return false;
    }

    std::vector<unsigned char> passwordHash;
    if (!OpenSSL_PBKDF2Helper::Compute_PBKDF2_HMAC_SHA512(password, passwordHashSalt, passwordHashKdfIterations, 64, passwordHash))
    {
        return false;
    }

    if (!OpenSSL_Base64Helper::Encode(passwordHash, base64EncodedPasswordHash))
    {
        return false;
    }

    return true;
}

bool SecureAccount::Verify(
    const std::vector<unsigned char>& password,
    const std::string& base64DerEncodedPublicKey,
    std::vector<unsigned char>& derEncodedPublicKey,
    const int& privateKeyKdfIterations,
    const std::string& base64EncodedPrivateKeySalt,
    const std::string& base64EncodedSecurePrivateKey,
    std::vector<unsigned char>& derEncodedPrivateKey)
{
    std::vector<unsigned char> securePrivateKey;
    if (!OpenSSL_Base64Helper::Decode(base64EncodedSecurePrivateKey, securePrivateKey))
    {
        return false;
    }

    const std::vector<unsigned char> aesIv(securePrivateKey.begin(), securePrivateKey.begin() + 16);
    const std::vector<unsigned char> encryptedPrivateKeyHmacSha256(securePrivateKey.begin() + 16, securePrivateKey.begin() + 48);
    const std::vector<unsigned char> encryptedPrivateKey(securePrivateKey.begin() + 48, securePrivateKey.end());

    std::vector<unsigned char> privateKeySalt;
    if (!OpenSSL_Base64Helper::Decode(base64EncodedPrivateKeySalt, privateKeySalt))
    {
        return false;
    }

    std::vector<unsigned char> derivedBytes;
    if (!OpenSSL_PBKDF2Helper::Compute_PBKDF2_HMAC_SHA512(password, privateKeySalt, privateKeyKdfIterations, 64, derivedBytes))
    {
        return false;
    }

    const std::vector<unsigned char> aeskey(derivedBytes.begin(), derivedBytes.begin() + 32);
    const std::vector<unsigned char> hmacKey(derivedBytes.begin() + 32, derivedBytes.end());

    std::vector<unsigned char> encryptedPrivateKeyHmacSha256Computed;
    if (!OpenSSL_HMACSHA256Helper::ComputeHMACSHA256(encryptedPrivateKey, hmacKey, encryptedPrivateKeyHmacSha256Computed))
    {
        return false;
    }

    if (encryptedPrivateKeyHmacSha256Computed != encryptedPrivateKeyHmacSha256)
    {
        return false;
    }

    std::string base64DerEncodedPrivateKey;
    if (!OpenSSL_AESHelper::Decrypt(aeskey, aesIv, encryptedPrivateKey, base64DerEncodedPrivateKey))
    {
        return false;
    }

    if (!OpenSSL_Base64Helper::Decode(base64DerEncodedPrivateKey, derEncodedPrivateKey))
    {
        return false;
    }

    if (!OpenSSL_Base64Helper::Decode(base64DerEncodedPublicKey, derEncodedPublicKey))
    {
        return false;
    }

    if (!OpenSSL_RSAHelper::ValidateKeys(derEncodedPublicKey, derEncodedPrivateKey))
    {
        return false;
    }

    return true;
}

bool SecureAccount::ChangePassword(
    const std::vector<unsigned char>& password,
    const std::vector<unsigned char>& derEncodedPrivateKey,
    const int& privateKeyKdfIterations,
    std::string& base64EncodedPrivateKeySalt,
    std::string& base64EncodedSecurePrivateKey,
    const int& passwordHashKdfIterations,
    std::string& base64EncodedPasswordHashSalt,
    std::string& base64EncodedPasswordHash)
{
    std::string base64DerEncodedPrivateKey;
    if (!OpenSSL_Base64Helper::Encode(derEncodedPrivateKey, base64DerEncodedPrivateKey))
    {
        return false;
    }

    std::vector<unsigned char> privateKeySalt;
    if (!OpenSSL_SaltHelper::GenerateSalt(24, privateKeySalt))
    {
        return false;
    }

    if (!OpenSSL_Base64Helper::Encode(privateKeySalt, base64EncodedPrivateKeySalt))
    {
        return false;
    }

    std::vector<unsigned char> derivedBytes; // [32 Bytes AES Key][32 Bytes HMAC Key]
    if (!OpenSSL_PBKDF2Helper::Compute_PBKDF2_HMAC_SHA512(password, privateKeySalt, privateKeyKdfIterations, 64, derivedBytes))
    {
        return false;
    }

    std::vector<unsigned char> aeskey(derivedBytes.begin(), derivedBytes.begin() + 32);
    std::vector<unsigned char> hmacKey(derivedBytes.begin() + 32, derivedBytes.end());

    std::vector<unsigned char> aesIv;
    if (!OpenSSL_IVHelper::GenerateIV(aesIv))
    {
        return false;
    }

    std::vector<unsigned char> encryptedPrivateKey;
    if (!OpenSSL_AESHelper::Encrypt(aeskey, aesIv, base64DerEncodedPrivateKey, encryptedPrivateKey))
    {
        return false;
    }

    std::vector<unsigned char> encryptedPrivateKeyHmacSha256;
    if (!OpenSSL_HMACSHA256Helper::ComputeHMACSHA256(encryptedPrivateKey, hmacKey, encryptedPrivateKeyHmacSha256))
    {
        return false;
    }

    std::vector<unsigned char> securePrivateKey;
    // Reserve enough space for all elements to improve performance
    securePrivateKey.reserve(aesIv.size() + encryptedPrivateKeyHmacSha256.size() + encryptedPrivateKey.size());
    // First insert iv at the beginning of securePrivateKey
    securePrivateKey.insert(securePrivateKey.end(), aesIv.begin(), aesIv.end());
    // Next insert hmac of encrypted private key
    securePrivateKey.insert(securePrivateKey.end(), encryptedPrivateKeyHmacSha256.begin(), encryptedPrivateKeyHmacSha256.end());
    // Next insert encrypted private key
    securePrivateKey.insert(securePrivateKey.end(), encryptedPrivateKey.begin(), encryptedPrivateKey.end());

    if (!OpenSSL_Base64Helper::Encode(securePrivateKey, base64EncodedSecurePrivateKey))
    {
        return false;
    }

    std::vector<unsigned char> passwordHashSalt;
    if (!OpenSSL_SaltHelper::GenerateSalt(24, passwordHashSalt))
    {
        return false;
    }

    if (!OpenSSL_Base64Helper::Encode(passwordHashSalt, base64EncodedPasswordHashSalt))
    {
        return false;
    }

    std::vector<unsigned char> passwordHash;
    if (!OpenSSL_PBKDF2Helper::Compute_PBKDF2_HMAC_SHA512(password, passwordHashSalt, passwordHashKdfIterations, 64, passwordHash))
    {
        return false;
    }

    if (!OpenSSL_Base64Helper::Encode(passwordHash, base64EncodedPasswordHash))
    {
        return false;
    }

    return true;
}

bool SecureAccount::EncryptUserAccountDetails(const std::string& emailAddress, const std::vector<unsigned char>& passwordSha256Hash, const std::vector<unsigned char>& derEncodedPrivateKeySha256Hash, const std::string& subscription, const std::string& defaultCloud, const std::string& userStatus, const std::string& numberOfDevices, const std::string& cardExpiry, const std::string& cardLastFourDigits, const std::string& subscriptionDate, const std::string& subscriptionExpiryDate, const std::string& activationCode, std::string& aesEncryptedBase64EncodedAccountDetails)
{
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    writer.StartObject();
    writer.Key("subscription");
    writer.String(subscription.c_str(), static_cast<rapidjson::SizeType>(subscription.length()));
    writer.Key("defaultCloud");
    writer.String(defaultCloud.c_str(), static_cast<rapidjson::SizeType>(defaultCloud.length()));
    writer.Key("userStatus");
    writer.String(userStatus.c_str(), static_cast<rapidjson::SizeType>(userStatus.length()));
    writer.Key("numberOfDevices");
    writer.String(numberOfDevices.c_str(), static_cast<rapidjson::SizeType>(numberOfDevices.length()));
    writer.Key("cardExpiry");
    writer.String(cardExpiry.c_str(), static_cast<rapidjson::SizeType>(cardExpiry.length()));
    writer.Key("cardLastFourDigits");
    writer.String(cardLastFourDigits.c_str(), static_cast<rapidjson::SizeType>(cardLastFourDigits.length()));
    writer.Key("subscriptionDate");
    writer.String(subscriptionDate.c_str(), static_cast<rapidjson::SizeType>(subscriptionDate.length()));
    writer.Key("subscriptionExpiryDate");
    writer.String(subscriptionExpiryDate.c_str(), static_cast<rapidjson::SizeType>(subscriptionExpiryDate.length()));
    writer.Key("activationCode");
    writer.String(activationCode.c_str(), static_cast<rapidjson::SizeType>(activationCode.length()));
    writer.EndObject();

    // Convert JSON string to std::vector<unsigned char>
    const char* jsonString = buffer.GetString();
    const std::vector<unsigned char> accountDetailsJson(jsonString, jsonString + buffer.GetSize());

    // Compute SHA256 hash of the AES Key Seed Data to ensure a fixed key length of 32 bytes for AES-256 encryption
    const std::vector<unsigned char> aesKeySeedDataHash = OpenSSL_SHA256Helper::ComputeAESKeySeedDataHash(emailAddress, passwordSha256Hash, derEncodedPrivateKeySha256Hash);

    if (!OpenSSL_Helper::AesEncryptBase64Encode(accountDetailsJson, aesKeySeedDataHash, aesEncryptedBase64EncodedAccountDetails))
    {
        return false;
    }

    return true;
}

bool SecureAccount::DecryptUserAccountDetails(const std::string& emailAddress, const std::vector<unsigned char>& passwordSha256Hash, const std::vector<unsigned char>& derEncodedPrivateKeySha256Hash, const std::string& aesEncryptedBase64EncodedAccountDetails, std::string& subscription, std::string& defaultCloud, std::string& userStatus, std::string& numberOfDevices, std::string& cardExpiry, std::string& cardLastFourDigits, std::string& subscriptionDate, std::string& subscriptionExpiryDate, std::string& activationCode)
{
    // Compute SHA256 hash of the AES Key Seed Data to ensure a fixed key length of 32 bytes for AES-256 encryption
    const std::vector<unsigned char> aesKeySeedDataHash = OpenSSL_SHA256Helper::ComputeAESKeySeedDataHash(emailAddress, passwordSha256Hash, derEncodedPrivateKeySha256Hash);

    std::vector<unsigned char> accountDetailsJsonVec;
    if (!OpenSSL_Helper::Base64DecodeAesDecrypt(aesEncryptedBase64EncodedAccountDetails, aesKeySeedDataHash, accountDetailsJsonVec))
    {
        return false;
    }
    std::string accountDetailsJson(accountDetailsJsonVec.begin(), accountDetailsJsonVec.end());


    // Start Parsing JSON:
    rapidjson::Document doc;

    if (doc.Parse(accountDetailsJson.c_str()).HasParseError())
    {
        return false;
    }

    // subscription
    if (!doc.HasMember("subscription") || !doc["subscription"].IsString())
    {
        return false;
    }
    subscription = doc["subscription"].GetString();

    // defaultCloud
    if (!doc.HasMember("defaultCloud") || !doc["defaultCloud"].IsString())
    {
        return false;
    }
    defaultCloud = doc["defaultCloud"].GetString();

    // userStatus
    if (!doc.HasMember("userStatus") || !doc["userStatus"].IsString())
    {
        return false;
    }
    userStatus = doc["userStatus"].GetString();

    // numberOfDevices
    if (!doc.HasMember("numberOfDevices") || !doc["numberOfDevices"].IsString())
    {
        return false;
    }
    numberOfDevices = doc["numberOfDevices"].GetString();

    // cardExpiry
    if (!doc.HasMember("cardExpiry") || !doc["cardExpiry"].IsString())
    {
        return false;
    }
    cardExpiry = doc["cardExpiry"].GetString();

    // cardLastFourDigits
    if (!doc.HasMember("cardLastFourDigits") || !doc["cardLastFourDigits"].IsString())
    {
        return false;
    }
    cardLastFourDigits = doc["cardLastFourDigits"].GetString();

    // subscriptionDate
    if (!doc.HasMember("subscriptionDate") || !doc["subscriptionDate"].IsString())
    {
        return false;
    }
    subscriptionDate = doc["subscriptionDate"].GetString();

    // activationCode
    if (!doc.HasMember("activationCode") || !doc["activationCode"].IsString())
    {
        return false;
    }
    activationCode = doc["activationCode"].GetString();

    // subscriptionExpiryDate
    if (!doc.HasMember("subscriptionExpiryDate") || !doc["subscriptionExpiryDate"].IsString())
    {
        return false;
    }
    subscriptionExpiryDate = doc["subscriptionExpiryDate"].GetString();

    return true;
}

