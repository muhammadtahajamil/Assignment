#include "OpenSSL_AESHelper.h"
#include <openssl/evp.h>
#include <openssl/aes.h>
#include <openssl/err.h>
#include <openssl/sha.h>

bool OpenSSL_AESHelper::Encrypt(const std::vector<unsigned char>& key, const std::vector<unsigned char>& iv, const std::string& plaintext, std::vector<unsigned char>& ciphertext)
{
    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx)
    {
        return false; // Failed to create EVP_CIPHER_CTX
    }

    int len = 0;
    int ciphertext_len = 0;

    // Initialize the encryption operation
    if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key.data(), iv.data()))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_EncryptInit_ex failed
    }

    // Provide the message to be encrypted, and obtain the encrypted output
    ciphertext.resize(plaintext.size() + AES_BLOCK_SIZE);
    if (1 != EVP_EncryptUpdate(ctx, ciphertext.data(), &len, reinterpret_cast<const unsigned char*>(plaintext.data()), plaintext.size()))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_EncryptUpdate failed
    }
    ciphertext_len = len;

    // Finalize the encryption
    if (1 != EVP_EncryptFinal_ex(ctx, ciphertext.data() + len, &len))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_EncryptFinal_ex failed
    }
    ciphertext_len += len;

    // Clean up
    EVP_CIPHER_CTX_free(ctx);

    // Resize the ciphertext vector to the actual size of the ciphertext
    ciphertext.resize(ciphertext_len);

    return true; // Encryption successful
}

bool OpenSSL_AESHelper::Encrypt(const std::vector<unsigned char>& key, const std::vector<unsigned char>& plaintext, std::vector<unsigned char>& ciphertext)
{
    // Ensure the key is 32 bytes (256 bits) for AES-256
    if (key.size() != 32) {
        return false; // Invalid key size
    }

    // Create and initialize the context
    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx)
    {
        return false; // Failed to create EVP_CIPHER_CTX
    }

    int len = 0;
    int ciphertext_len = 0;

    // Generate the SHA-256 hash of the key and use the first 16 bytes as the IV
    unsigned char iv[16]; // AES-256-CBC uses a 16-byte IV
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256(key.data(), key.size(), hash);
    memcpy(iv, hash, 16); // Use the first 16 bytes of the hash as the IV

    // Initialize the encryption operation
    if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key.data(), reinterpret_cast<const unsigned char*>(iv)))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_EncryptInit_ex failed
    }

    // Provide the message to be encrypted, and obtain the encrypted output
    ciphertext.resize(plaintext.size() + AES_BLOCK_SIZE);
    if (1 != EVP_EncryptUpdate(ctx, ciphertext.data(), &len, reinterpret_cast<const unsigned char*>(plaintext.data()), plaintext.size()))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_EncryptUpdate failed
    }
    ciphertext_len = len;

    // Finalize the encryption
    if (1 != EVP_EncryptFinal_ex(ctx, ciphertext.data() + len, &len))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_EncryptFinal_ex failed
    }
    ciphertext_len += len;

    // Clean up
    EVP_CIPHER_CTX_free(ctx);

    // Resize the ciphertext vector to the actual size of the ciphertext
    ciphertext.resize(ciphertext_len);

    return true; // Encryption successful
}

bool OpenSSL_AESHelper::Decrypt(const std::vector<unsigned char>& key, const std::vector<unsigned char>& ciphertext, std::vector<unsigned char>& plaintext)
{
    // Ensure the key is 32 bytes (256 bits) for AES-256
    if (key.size() != 32) {
        return false; // Invalid key size
    }

    // Create and initialize the context
    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx)
    {
        return false; // Failed to create EVP_CIPHER_CTX
    }

    int len = 0;
    int plaintext_len = 0;

    // Generate the SHA-256 hash of the key and use the first 16 bytes as the IV
    unsigned char iv[16]; // AES-256-CBC uses a 16-byte IV
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256(key.data(), key.size(), hash);
    memcpy(iv, hash, 16); // Use the first 16 bytes of the hash as the IV

    // Initialize the decryption operation with AES-256-CBC
    if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key.data(), iv))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_DecryptInit_ex failed
    }

    // Provide the ciphertext to be decrypted and obtain the plaintext output
    plaintext.resize(ciphertext.size() + EVP_CIPHER_block_size(EVP_aes_256_cbc()));
    if (1 != EVP_DecryptUpdate(ctx, plaintext.data(), &len, ciphertext.data(), ciphertext.size()))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_DecryptUpdate failed
    }
    plaintext_len = len;

    // Finalize the decryption
    if (1 != EVP_DecryptFinal_ex(ctx, plaintext.data() + len, &len))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_DecryptFinal_ex failed
    }
    plaintext_len += len;

    // Clean up
    EVP_CIPHER_CTX_free(ctx);

    // Resize plaintext to the actual decrypted size
    plaintext.resize(plaintext_len);

    return true; // Decryption successful
}


bool OpenSSL_AESHelper::Decrypt(const std::vector<unsigned char>& key, const std::vector<unsigned char>& iv, const std::vector<unsigned char>& ciphertext, std::string& plaintext)
{
    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx)
    {
        return false; // Failed to create EVP_CIPHER_CTX
    }

    int len = 0;
    int plaintext_len = 0;

    // Initialize the decryption operation. The key and IV must be the same as that used for encryption.
    if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key.data(), iv.data()))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_DecryptInit_ex failed
    }

    // Provide the message to be decrypted, and obtain the plaintext output.
    std::vector<unsigned char> buffer(ciphertext.size()); // Buffer for the decrypted text
    if (1 != EVP_DecryptUpdate(ctx, buffer.data(), &len, ciphertext.data(), ciphertext.size()))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_DecryptUpdate failed
    }
    plaintext_len = len;

    // Finalize the decryption
    if (1 != EVP_DecryptFinal_ex(ctx, buffer.data() + len, &len))
    {
        EVP_CIPHER_CTX_free(ctx);
        return false; // EVP_DecryptFinal_ex failed
    }
    plaintext_len += len;

    // Clean up
    EVP_CIPHER_CTX_free(ctx);

    // Set the plaintext size and content
    plaintext = std::string(buffer.begin(), buffer.begin() + plaintext_len);

    return true; // Decryption successful
}
