//
//  WrappingKeyRequester.h
//  FolderLock
//
//  Created by MacBook on 06/08/2024.
//

#ifndef WrappingKeyRequester_h
#define WrappingKeyRequester_h

@interface WrappingKeyRequester : NSObject

+ (NSString *)getWrappingKeyForUserId:(NSString *)userId folderId:(NSString *)folderId;
+ (NSString *)callWrappingKeyAPI:(NSString *)userId folderId:(NSString *)folderId;

@end

#endif /* WrappingKeyRequester_h */
