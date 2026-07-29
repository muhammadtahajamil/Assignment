//
//  WrappingKeyCache.h
//  FolderLock
//
//  Created by MacBook on 06/08/2024.
//

#ifndef WrappingKeyCache_h
#define WrappingKeyCache_h

#import <Foundation/Foundation.h>
#import "WrappingKeyCacheValue.h"

@interface WrappingKeyCache : NSObject

+ (void)putWithUserId:(NSString *)userId folderId:(NSString *)folderId cacheValue:(WrappingKeyCacheValue *)cacheValue;
+ (WrappingKeyCacheValue *)getWithUserId:(NSString *)userId folderId:(NSString *)folderId;
+ (void)clearCache;

@end


#endif /* WrappingKeyCache_h */
