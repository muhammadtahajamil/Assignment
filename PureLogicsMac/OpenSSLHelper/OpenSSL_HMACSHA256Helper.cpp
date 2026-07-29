#include "OpenSSL_HMACSHA256Helper.h"
#include <openssl/evp.h>
#include <openssl/hmac.h>
#include <openssl/params.h>


// ComputeHMACSHA256 for std::string
bool OpenSSL_HMACSHA256Helper::ComputeHMACSHA256(const std::string& data, const std::string& key, std::string& output)
{
    EVP_MAC* mac = EVP_MAC_fetch(NULL, "HMAC", NULL);
    if (mac == NULL) {
        return false;
    }

    EVP_MAC_CTX* ctx = EVP_MAC_CTX_new(mac);
    if (ctx == NULL) {
        EVP_MAC_free(mac);
        return false;
    }

    OSSL_PARAM params[] = {
        OSSL_PARAM_construct_utf8_string("digest", (char*)"SHA256", 0),
        OSSL_PARAM_END
    };

    if (!EVP_MAC_init(ctx, reinterpret_cast<const unsigned char*>(key.c_str()), key.length(), params)) {
        EVP_MAC_CTX_free(ctx);
        EVP_MAC_free(mac);
        return false;
    }

    if (!EVP_MAC_update(ctx, reinterpret_cast<const unsigned char*>(data.c_str()), data.length())) {
        EVP_MAC_CTX_free(ctx);
        EVP_MAC_free(mac);
        return false;
    }

    unsigned char result[EVP_MAX_MD_SIZE];
    size_t len = sizeof(result);

    if (!EVP_MAC_final(ctx, result, &len, sizeof(result))) {
        EVP_MAC_CTX_free(ctx);
        EVP_MAC_free(mac);
        return false;
    }

    EVP_MAC_CTX_free(ctx);
    EVP_MAC_free(mac);

    output.assign(reinterpret_cast<char*>(result), len);
    return true;
}

// ComputeHMACSHA256 for std::vector<unsigned char>
bool OpenSSL_HMACSHA256Helper::ComputeHMACSHA256(const std::vector<unsigned char>& data, const std::vector<unsigned char>& key, std::vector<unsigned char>& output)
{
    EVP_MAC* mac = EVP_MAC_fetch(NULL, "HMAC", NULL);
    if (mac == NULL) {
        return false;
    }

    EVP_MAC_CTX* ctx = EVP_MAC_CTX_new(mac);
    if (ctx == NULL) {
        EVP_MAC_free(mac);
        return false;
    }

    OSSL_PARAM params[] = {
        OSSL_PARAM_construct_utf8_string("digest", (char*)"SHA256", 0),
        OSSL_PARAM_END
    };

    if (!EVP_MAC_init(ctx, key.data(), key.size(), params)) {
        EVP_MAC_CTX_free(ctx);
        EVP_MAC_free(mac);
        return false;
    }

    if (!EVP_MAC_update(ctx, data.data(), data.size())) {
        EVP_MAC_CTX_free(ctx);
        EVP_MAC_free(mac);
        return false;
    }

    std::vector<unsigned char> result(EVP_MAX_MD_SIZE);
    size_t len = result.size();

    if (!EVP_MAC_final(ctx, result.data(), &len, result.size())) {
        EVP_MAC_CTX_free(ctx);
        EVP_MAC_free(mac);
        return false;
    }

    EVP_MAC_CTX_free(ctx);
    EVP_MAC_free(mac);

    result.resize(len);
    output.swap(result);
    return true;
}