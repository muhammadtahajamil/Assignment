#include "OpenSSL_RSAHelper.h"

#include "OpenSSL_Base64Helper.h"
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/encoder.h>

bool OpenSSL_RSAHelper::GenerateKeys(std::vector<unsigned char>& derEncodedPublicKey, std::vector<unsigned char>& derEncodedPrivateKey) {
    // Generate RSA key pair
    EVP_PKEY_CTX* ctx = EVP_PKEY_CTX_new_id(EVP_PKEY_RSA, nullptr);
    if (ctx == nullptr) {
        return false; // Failed to create EVP_PKEY_CTX
    }

    if (EVP_PKEY_keygen_init(ctx) <= 0 || EVP_PKEY_CTX_set_rsa_keygen_bits(ctx, 4096) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        return false; // Failed to initialize key generation or set key length
    }

    EVP_PKEY* evp_keypair = nullptr;
    if (EVP_PKEY_keygen(ctx, &evp_keypair) <= 0 || evp_keypair == nullptr) {
        EVP_PKEY_CTX_free(ctx);
        return false; // Failed to generate RSA key pair
    }

    // Convert public key to DER format
    unsigned char* der_public_key_data = nullptr;
    int der_public_key_length = i2d_PUBKEY(evp_keypair, &der_public_key_data);
    if (der_public_key_length <= 0 || der_public_key_data == nullptr) {
        EVP_PKEY_free(evp_keypair);
        EVP_PKEY_CTX_free(ctx);
        return false; // Failed to convert public key to DER format
    }
    derEncodedPublicKey.assign(der_public_key_data, der_public_key_data + der_public_key_length);
    OPENSSL_free(der_public_key_data);

    // Convert private key to DER format
    unsigned char* der_private_key_data = nullptr;
    int der_private_key_length = i2d_PrivateKey(evp_keypair, &der_private_key_data);
    if (der_private_key_length <= 0 || der_private_key_data == nullptr) {
        OPENSSL_free(der_public_key_data); // Free previously allocated memory
        EVP_PKEY_free(evp_keypair);
        EVP_PKEY_CTX_free(ctx);
        return false; // Failed to convert private key to DER format
    }
    derEncodedPrivateKey.assign(der_private_key_data, der_private_key_data + der_private_key_length);
    OPENSSL_free(der_private_key_data);

    // Free EVP_PKEY and EVP_PKEY_CTX
    EVP_PKEY_free(evp_keypair);
    EVP_PKEY_CTX_free(ctx);

    return true; // Successfully generated and encoded RSA key pair
}

bool OpenSSL_RSAHelper::ValidateKeys(const std::vector<unsigned char>& derPublicKey, const std::vector<unsigned char>& derPrivateKey) {
    // Parse DER-encoded public key
    const unsigned char* der_public_key_data = derPublicKey.data();
    EVP_PKEY* evp_public_key = d2i_PUBKEY(nullptr, &der_public_key_data, derPublicKey.size());
    if (evp_public_key == nullptr) {
        // Failed to parse public key
        return false;
    }

    // Check if the public key is RSA
    if (EVP_PKEY_id(evp_public_key) != EVP_PKEY_RSA) {
        // Not an RSA key
        EVP_PKEY_free(evp_public_key);
        return false;
    }
    EVP_PKEY_free(evp_public_key);

    // Parse DER-encoded private key
    const unsigned char* der_private_key_data = derPrivateKey.data();
    EVP_PKEY* evp_private_key = d2i_PrivateKey(EVP_PKEY_RSA, nullptr, &der_private_key_data, derPrivateKey.size());
    if (evp_private_key == nullptr) {
        // Failed to parse private key
        return false;
    }

    // Check if the private key is RSA
    if (EVP_PKEY_id(evp_private_key) != EVP_PKEY_RSA) {
        // Not an RSA key
        EVP_PKEY_free(evp_private_key);
        return false;
    }
    EVP_PKEY_free(evp_private_key);

    return true; // Both keys are valid RSA keys
}

bool OpenSSL_RSAHelper::Encrypt(
    const std::vector<unsigned char>& data,
    const std::vector<unsigned char>& derEncodedPublicKey,
    std::vector<unsigned char>& encryptedData)
{
    // Convert the string to a pointer for use with OpenSSL's d2i_PUBKEY function
    const unsigned char* derPublicKeyPtr = reinterpret_cast<const unsigned char*>(derEncodedPublicKey.data());
    long derPublicKeyDataLength = static_cast<long>(derEncodedPublicKey.size());

    // Convert the DER-encoded public key into an EVP_PKEY structure
    EVP_PKEY* evp_key = d2i_PUBKEY(nullptr, &derPublicKeyPtr, derPublicKeyDataLength);
    if (evp_key == nullptr) {
        // Failed to decode the DER-encoded public key
        return false;
    }

    // Check if the EVP_PKEY contains an RSA key
    if (EVP_PKEY_id(evp_key) != EVP_PKEY_RSA) {
        // Not an RSA key
        EVP_PKEY_free(evp_key);
        return false;
    }

    // Create an EVP encryption context
    EVP_PKEY_CTX* ctx = EVP_PKEY_CTX_new(evp_key, nullptr);
    if (ctx == nullptr) {
        EVP_PKEY_free(evp_key);
        return false; // Failed to create EVP context
    }

    // Initialize the context for encryption
    if (EVP_PKEY_encrypt_init(ctx) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(evp_key);
        return false; // Failed to initialize encryption context
    }

    // Set padding mode (RSA_PKCS1_OAEP_PADDING for OAEP, RSA_PKCS1_PADDING for PKCS#1 v1.5)
    if (EVP_PKEY_CTX_set_rsa_padding(ctx, RSA_PKCS1_OAEP_PADDING) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(evp_key);
        return false; // Failed to set padding mode
    }

    // Determine the maximum size of the encrypted data
    size_t maxEncryptedSize = 0;
    if (EVP_PKEY_encrypt(ctx, nullptr, &maxEncryptedSize, data.data(), data.size()) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(evp_key);
        return false; // Failed to determine maximum encrypted size
    }

    // Resize encryptedData to the maximum possible size
    encryptedData.resize(maxEncryptedSize);

    // Encrypt the data
    size_t encryptedLength = maxEncryptedSize;
    if (EVP_PKEY_encrypt(ctx, encryptedData.data(), &encryptedLength, data.data(), data.size()) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(evp_key);
        return false; // Encryption failed
    }

    // Resize encryptedData to the actual encrypted length
    encryptedData.resize(encryptedLength);

    // Free the EVP_PKEY structure and context after use
    EVP_PKEY_CTX_free(ctx);
    EVP_PKEY_free(evp_key);

    return true; // Successfully encrypted data
}

bool OpenSSL_RSAHelper::Decrypt(
    const std::vector<unsigned char>& encryptedData,
    const std::vector<unsigned char>& derEncodedPrivateKey,
    std::vector<unsigned char>& decryptedData)
{
    // Convert the string to a pointer for use with OpenSSL's d2i_PrivateKey function
    const unsigned char* derPrivateKeyPtr = reinterpret_cast<const unsigned char*>(derEncodedPrivateKey.data());
    long derPrivateKeyDataLength = static_cast<long>(derEncodedPrivateKey.size());

    // Convert the DER-encoded private key into an EVP_PKEY structure
    EVP_PKEY* evp_key = d2i_PrivateKey(EVP_PKEY_RSA, nullptr, &derPrivateKeyPtr, derPrivateKeyDataLength);
    if (evp_key == nullptr) {
        // Failed to decode the DER-encoded private key
        return false;
    }

    // Check if the EVP_PKEY contains an RSA key
    if (EVP_PKEY_id(evp_key) != EVP_PKEY_RSA) {
        // Not an RSA key
        EVP_PKEY_free(evp_key);
        return false;
    }

    // Create an EVP decryption context
    EVP_PKEY_CTX* ctx = EVP_PKEY_CTX_new(evp_key, nullptr);
    if (ctx == nullptr) {
        EVP_PKEY_free(evp_key);
        return false; // Failed to create EVP context
    }

    // Initialize the context for decryption
    if (EVP_PKEY_decrypt_init(ctx) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(evp_key);
        return false; // Failed to initialize decryption context
    }

    // Set RSA padding mode to OAEP (RSA_PKCS1_OAEP_PADDING for OAEP)
    if (EVP_PKEY_CTX_set_rsa_padding(ctx, RSA_PKCS1_OAEP_PADDING) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(evp_key);
        return false; // Failed to set padding mode
    }

    // Determine the maximum size of the decrypted data
    size_t maxDecryptedSize = 0;
    if (EVP_PKEY_decrypt(ctx, nullptr, &maxDecryptedSize, encryptedData.data(), encryptedData.size()) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(evp_key);
        return false; // Failed to determine maximum decrypted size
    }

    // Resize the output vector to the maximum decrypted size
    decryptedData.resize(maxDecryptedSize);

    // Perform the decryption
    size_t decryptedLength = maxDecryptedSize;
    if (EVP_PKEY_decrypt(ctx, decryptedData.data(), &decryptedLength, encryptedData.data(), encryptedData.size()) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(evp_key);
        return false; // Decryption failed
    }

    // Resize the decrypted data to the actual decrypted length
    decryptedData.resize(decryptedLength);

    // Free the EVP_PKEY structure and context after use
    EVP_PKEY_CTX_free(ctx);
    EVP_PKEY_free(evp_key);

    return true; // Successfully decrypted data
}
