//
//  OpenSSL_AESKeyHelper_Wrapper.h
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#ifndef OpenSSL_AESKeyHelper_Wrapper_h
#define OpenSSL_AESKeyHelper_Wrapper_h

#import <Foundation/Foundation.h>

@interface OpenSSL_AESKeyHelper_Wrapper : NSObject

+ (BOOL)generateAes256Key:(NSMutableData **)aes256Key;

@end


#endif /* OpenSSL_AESKeyHelper_Wrapper_h */
