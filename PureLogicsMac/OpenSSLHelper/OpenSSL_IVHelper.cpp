#include "OpenSSL_IVHelper.h"
#include <openssl/rand.h>

bool OpenSSL_IVHelper::GenerateIV(std::vector<unsigned char>& iv)
{
    iv.clear();
    iv.resize(16);

    // Generate a random secure IV
    if (RAND_bytes(iv.data(), iv.size()) != 1)
    {
        // Error generating random IV.
        return false;
    }

    return true;
}
