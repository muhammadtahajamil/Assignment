#ifndef SECUREACCOUNT_H
#define SECUREACCOUNT_H

#include <string>
#include <vector>

class SecureAccount
{
private:
    SecureAccount() = delete;

public:
    //in:
    // password,
    // privateKeyKdfIterations,
    // passwordHashKdfIterations
    //out:
    // all other parameters
    static bool Create(
        const std::vector<unsigned char>& password,
        std::vector<unsigned char>& derEncodedPublicKey,
        std::vector<unsigned char>& derEncodedPrivateKey,
        std::string& base64DerEncodedPublicKey,
        const int& privateKeyKdfIterations,
        std::string& base64EncodedPrivateKeySalt,
        std::string& base64EncodedSecurePrivateKey,
        const int& passwordHashKdfIterations,
        std::string& base64EncodedPasswordHashSalt,
        std::string& base64EncodedPasswordHash
    );
        
    //in:
    // password,
    // base64DerEncodedPublicKey,
    // privateKeyKdfIterations,
    // base64EncodedPrivateKeySalt,
    // base64EncodedSecurePrivateKey
    //out:
    // derEncodedPublicKey,
    // derEncodedPrivateKey
    static bool Verify(
        const std::vector<unsigned char>& password,
        const std::string& base64DerEncodedPublicKey,
        std::vector<unsigned char>& derEncodedPublicKey,
        const int& privateKeyKdfIterations,
        const std::string& base64EncodedPrivateKeySalt,
        const std::string& base64EncodedSecurePrivateKey,
        std::vector<unsigned char>& derEncodedPrivateKey
    );

    //in:
    // password,
    // base64DerEncodedPrivateKey,
    // privateKeyKdfIterations,
    // passwordHashKdfIterations
    //out:
    // all other parameters
    static bool ChangePassword(
        const std::vector<unsigned char>& password,
        const std::vector<unsigned char>& derEncodedPrivateKey,
        const int& privateKeyKdfIterations,
        std::string& base64EncodedPrivateKeySalt,
        std::string& base64EncodedSecurePrivateKey,
        const int& passwordHashKdfIterations,
        std::string& base64EncodedPasswordHashSalt,
        std::string& base64EncodedPasswordHash
    );

    static bool EncryptUserAccountDetails(
        const std::string& emailAddress,
        const std::vector<unsigned char>& passwordSha256Hash,
        const std::vector<unsigned char>& derEncodedPrivateKeySha256Hash,
        const std::string& subscription,
        const std::string& defaultCloud,
        const std::string& userStatus,
        const std::string& numberOfDevices,
        const std::string& cardExpiry,
        const std::string& cardLastFourDigits,
        const std::string& subscriptionDate,
        const std::string& subscriptionExpiryDate,
        const std::string& activationCode,
        std::string& aesEncryptedBase64EncodedAccountDetails);

    static bool DecryptUserAccountDetails(
        const std::string& emailAddress,
        const std::vector<unsigned char>& passwordSha256Hash,
        const std::vector<unsigned char>& derEncodedPrivateKeySha256Hash,
        const std::string& aesEncryptedBase64EncodedAccountDetails,
        std::string& subscription,
        std::string& defaultCloud,
        std::string& userStatus,
        std::string& numberOfDevices,
        std::string& cardExpiry,
        std::string& cardLastFourDigits,
        std::string& subscriptionDate,
        std::string& subscriptionExpiryDate,
        std::string& activationCode);
};

#endif
