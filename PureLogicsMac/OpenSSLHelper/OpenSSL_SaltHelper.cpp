#include "OpenSSL_SaltHelper.h"
#include <openssl/rand.h>

bool OpenSSL_SaltHelper::GenerateSalt(const unsigned int size, std::vector<unsigned char>& salt)
{
    salt.clear();
    salt.resize(size);

    // Generate a random secure salt
   if (RAND_bytes(salt.data(), salt.size()) != 1)
   {
       // Error generating random salt.
       return false;
   }

    return true;
}
