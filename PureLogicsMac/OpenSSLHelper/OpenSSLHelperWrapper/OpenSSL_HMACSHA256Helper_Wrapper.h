//
//  OpenSSL_HMACSHA256Helper_Wrapper.h
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#ifndef OpenSSL_HMACSHA256Helper_Wrapper_h
#define OpenSSL_HMACSHA256Helper_Wrapper_h

#import <Foundation/Foundation.h>

@interface OpenSSL_HMACSHA256Helper_Wrapper : NSObject

+ (BOOL)computeHMACSHA256:(const NSString *)data key:(const NSString *)key ouptut:(NSMutableString *)output;

+ (BOOL)computeHMACSHA256:(const NSData *)data key:(const NSData *)key output:(NSMutableData *)output;

@end

#endif /* OpenSSL_HMACSHA256Helper_Wrapper_h */
