//
//  OpenSSL_Base64Helper_Wrapper.h
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#ifndef OpenSSL_Base64Helper_Wrapper_h
#define OpenSSL_Base64Helper_Wrapper_h
#import <Foundation/Foundation.h>

@interface OpenSSL_Base64Helper_Wrapper : NSObject

+ (BOOL)encode:(const NSData *)data output:(NSString **)output;
+ (BOOL)decode:(const NSString *)data output:(NSMutableData **)output;

@end


#endif /* OpenSSL_Base64Helper_Wrapper_h */
