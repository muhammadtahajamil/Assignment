#include "OpenSSL_Base64Helper.h"
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>

bool OpenSSL_Base64Helper::Encode(const std::vector<unsigned char>& data, std::string& output)
{
    BIO* bmem;
    BIO* b64;
    BUF_MEM* bptr;

    b64 = BIO_new(BIO_f_base64());
    if (!b64)
    {
        return false; // Check if BIO_new failed for b64
    }

    BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL); // Ignore newlines - write everything in one line

    bmem = BIO_new(BIO_s_mem());
    if (!bmem)
    {   // Check if BIO_new failed for bmem
        BIO_free_all(b64); // Clean up b64 before returning
        return false;
    }

    b64 = BIO_push(b64, bmem);
    if (BIO_write(b64, data.data(), data.size()) <= 0)
        { // Check BIO_write failure
        BIO_free_all(b64); // Clean up on failure
        return false;
    }

    if (BIO_flush(b64) <= 0)
    {   // Check BIO_flush failure
        BIO_free_all(b64); // Clean up on failure
        return false;
    }

    if (BIO_get_mem_ptr(b64, &bptr) <= 0)
    {   // Check BIO_get_mem_ptr failure
        BIO_free_all(b64); // Clean up on failure
        return false;
    }

    // Directly assign to the output parameter
    output.assign(bptr->data, bptr->length);
    BIO_free_all(b64);

    return true; // Return true on successful completion
}

bool OpenSSL_Base64Helper::Decode(const std::string& data, std::vector<unsigned char>& output)
{
    BIO* b64;
    BIO* bmem;

    // Initialize BIO for base64.
    b64 = BIO_new(BIO_f_base64());
    if (!b64)
    {
        return false; // Check for BIO allocation failure
    }

    BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL); // Do not use newlines to flush buffer

    // Initialize BIO with memory buffer containing input data.
    bmem = BIO_new_mem_buf(const_cast<void*>(static_cast<const void*>(data.data())), static_cast<int>(data.size()));
    if (!bmem)
    {   // Check for BIO allocation failure
        BIO_free_all(b64); // Clean up already allocated resources
        return false;
    }

    // Chain base64 BIO and memory BIO.
    b64 = BIO_push(b64, bmem);

    // Prepare a buffer to hold the decoded data.
    std::vector<unsigned char> buffer(data.size()); // Decoded data will be smaller than the input.
    int decoded_size = BIO_read(b64, buffer.data(), buffer.size());
    if (decoded_size < 0)
    {
        BIO_free_all(b64); // Ensure to free resources on error
        return false; // Indicate failure
    }

    // Resize buffer to actual decoded size and assign to output.
    buffer.resize(decoded_size);
    output.swap(buffer); // Efficiently assign the decoded buffer to output

    BIO_free_all(b64); // Free all BIOs

    return true; // Indicate success
}
