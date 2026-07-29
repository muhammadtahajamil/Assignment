//
//  WrappingKeyCacheValue.m
//  FolderLock
//
//  Created by MacBook on 06/08/2024.
//

#import <Foundation/Foundation.h>

#import "WrappingKeyCacheValue.h"

@interface WrappingKeyCacheValue ()


@end

@implementation WrappingKeyCacheValue

- (instancetype)initWithStatus:(NSString *)status encWrappingKey:(NSString *)encWrappingKey {
    self = [super init];
    if (self) {
        _status = status;
        _encWrappingKey = encWrappingKey;
    }
    return self;
}

@end
