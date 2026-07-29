//
//  WrappingKeyCacheValue.h
//  FolderLock
//
//  Created by MacBook on 06/08/2024.
//

#ifndef WrappingKeyCacheValue_h
#define WrappingKeyCacheValue_h

#import <Foundation/Foundation.h>

@interface WrappingKeyCacheValue : NSObject

@property (nonatomic, strong, readonly) NSString *status;
@property (nonatomic, strong, readonly) NSString *encWrappingKey;

- (instancetype)initWithStatus:(NSString *)status encWrappingKey:(NSString *)encWrappingKey;

@end


#endif /* WrappingKeyCacheValue_h */
