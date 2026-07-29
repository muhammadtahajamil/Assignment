#include "OpenSSL_AESKeyHelper.h"
#include <openssl/rand.h>

bool OpenSSL_AESKeyHelper::GenerateAes256Key(std::vector<unsigned char>& aes256Key)
{
    aes256Key.clear();
    aes256Key.resize(32); // AES 256 key size is 32 Bytes.

    // Generate a random secure aes 256 key
    if (RAND_bytes(aes256Key.data(), aes256Key.size()) != 1)
    {
        // Error generating random aes 256 key.
        return false;
    }

    return true;
}
