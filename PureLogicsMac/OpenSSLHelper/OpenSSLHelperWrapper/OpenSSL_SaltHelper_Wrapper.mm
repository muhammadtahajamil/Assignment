//
//  OpenSSL_SaltHelper_Wrapper.m
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import "OpenSSL_SaltHelper_Wrapper.h"
#import "OpenSSL_SaltHelper.h"

@implementation OpenSSL_SaltHelper_Wrapper

+ (BOOL)generateSalt:(const unsigned int)size salt:(NSMutableData *)salt {
    if (!salt || size == 0) {
            return false;
    }
        
    // Resize the salt to the specified size
    [salt setLength:size];
        
    // Call the C++ function
    bool result = OpenSSL_SaltHelper::GenerateSalt(size, *(std::vector<unsigned char> *)[salt mutableBytes]);
        
    return result;
}

@end
