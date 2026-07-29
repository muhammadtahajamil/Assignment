//
//  OpenSSL_SaltHelper_Wrapper.h
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#ifndef OpenSSL_SaltHelper_Wrapper_h
#define OpenSSL_SaltHelper_Wrapper_h

#import <Foundation/Foundation.h>

@interface OpenSSL_SaltHelper_Wrapper : NSObject

+ (BOOL)generateSalt:(const unsigned int)size salt:(NSMutableData *)salt;

@end


#endif /* OpenSSL_SaltHelper_Wrapper_h */
