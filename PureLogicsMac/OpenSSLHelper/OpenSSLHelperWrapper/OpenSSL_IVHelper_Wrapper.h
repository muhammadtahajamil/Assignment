//
//  OpenSSL_IVHelper_Wrapper.h
//  FolderLock
//
//  Created by MacBook on 21/05/2024.
//

#ifndef OpenSSL_IVHelper_Wrapper_h
#define OpenSSL_IVHelper_Wrapper_h

#import <Foundation/Foundation.h>

@interface OpenSSL_IVHelper_Wrapper : NSObject

+ (BOOL)generateIV:(NSMutableData *)iv;

@end


#endif /* OpenSSL_IVHelper_Wrapper_h */
