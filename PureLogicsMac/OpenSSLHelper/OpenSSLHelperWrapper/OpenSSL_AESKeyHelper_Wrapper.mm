//
//  OpenSSL_AESKeyHelper_Wrapper.m
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import "OpenSSL_AESKeyHelper_Wrapper.h"
#import "OpenSSL_AESKeyHelper.h"

@implementation OpenSSL_AESKeyHelper_Wrapper

+ (BOOL)generateAes256Key:(NSMutableData **)aes256Key {
    
    std::vector<unsigned char> cppAes256Key;
    
    if (!OpenSSL_AESKeyHelper::GenerateAes256Key(cppAes256Key)) {
        return NO; // Error occurred
    }
    
    
    *aes256Key = [NSMutableData dataWithBytes:cppAes256Key.data() length:cppAes256Key.size()];
    
    return YES;
}

@end
